const functions = require('firebase-functions');
const admin = require('firebase-admin');
const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');

admin.initializeApp();

/**
 * Triggered when a file is uploaded to Cloud Storage.
 * Resizes the image to max 1080x1920 and converts to WebP.
 * Saves to the 'optimized' bucket path.
 */
exports.optimizeImage = functions.storage.object().onFinalize(async (object) => {
  const fileBucket = object.bucket; // The Storage bucket that contains the file.
  const filePath = object.name; // File path in the bucket.
  const contentType = object.contentType; // File content type.

  // Exit if this is triggered on a file that is not an image.
  if (!contentType.startsWith('image/')) {
    return console.log('This is not an image.');
  }

  // Exit if the image is already optimized (to avoid infinite loops).
  if (filePath.startsWith('optimized/')) {
    return console.log('Already optimized.');
  }

  const fileName = path.basename(filePath);
  const bucket = admin.storage().bucket(fileBucket);
  const tempFilePath = path.join(os.tmpdir(), fileName);
  const tempOutputPath = path.join(os.tmpdir(), `optimized_${fileName}.webp`);

  // Structure: wallpapers/{userId}/{filename} -> optimized/{userId}/{filename}.webp
  const dirName = path.dirname(filePath);
  // e.g. wallpapers/user123 -> optimized/user123
  const outputDir = dirName.replace('wallpapers', 'optimized');
  const destination = path.normalize(path.join(outputDir, `${path.parse(fileName).name}.webp`));

  // Download file from bucket.
  await bucket.file(filePath).download({ destination: tempFilePath });
  console.log('Image downloaded locally to', tempFilePath);

  // Resize and convert using ImageMagick (pre-installed in Cloud Functions environment)
  // Converting to WebP and resizing to fit within 1080x1920.
  // '>' flag ensures we only shrink, not enlarge.
  await spawn('convert', [
    tempFilePath,
    '-resize', '1080x1920>',
    '-quality', '80',
    '-define', 'webp:lossless=false',
    tempOutputPath
  ]);

  console.log('Image resized and converted to WebP at', tempOutputPath);

  // Uploading the optimized image.
  await bucket.upload(tempOutputPath, {
    destination: destination,
    metadata: {
      contentType: 'image/webp',
      cacheControl: 'public, max-age=31536000', // Cache for 1 year
    },
  });

  console.log('Optimized image uploaded to', destination);

  // Cleanup local files to free up disk space.
  fs.unlinkSync(tempFilePath);
  fs.unlinkSync(tempOutputPath);

  return null;
});

/**
 * Callable function to get smart crop coordinates using Gemini API.
 * Expects { imageBase64: string } or { imageUrl: string } in data.
 * Returns { cropRect: { ymin, xmin, ymax, xmax } }.
 */
exports.getSmartCropCoordinates = functions.runWith({
  secrets: ['GEMINI_API_KEY'], // Accessing the secret
  timeoutSeconds: 60,
  memory: '1GB',
}).https.onCall(async (data, context) => {
  // Ensure the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called while authenticated.');
  }

  const imageBase64 = data.imageBase64;

  if (!imageBase64) {
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with an "imageBase64" argument.');
  }

  try {
    const { GoogleGenerativeAI } = require("@google/generative-ai");

    // Access the API key from the environment/secret
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new functions.https.HttpsError('failed-precondition', 'Gemini API Key not configured.');
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-pro-vision" });

    const prompt = "Analyze this image for a mobile wallpaper. Find the main subject (face, pet, object). Return the bounding box of the subject as a JSON object: { \"ymin\": 0.0, \"xmin\": 0.0, \"ymax\": 1.0, \"xmax\": 1.0 }. Ensure coordinates are normalized 0.0 to 1.0. Do not include markdown formatting.";

    const imagePart = {
      inlineData: {
        data: imageBase64,
        mimeType: "image/jpeg",
      },
    };

    const result = await model.generateContent([prompt, imagePart]);
    const response = await result.response;
    const text = response.text();

    // Clean up potential markdown code blocks
    const jsonString = text.replace(/```json/g, '').replace(/```/g, '').trim();
    const cropData = JSON.parse(jsonString);

    return { cropRect: cropData };

  } catch (error) {
    console.error("Gemini API Error:", error);
    throw new functions.https.HttpsError('internal', 'Failed to analyze image.', error.message);
  }
});
