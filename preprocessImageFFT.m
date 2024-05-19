function preprocessedImg = preprocessImageFFT(img)
    % Step 1: Convert the image to grayscale
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Step 2: Compute the FFT of the image
    imgFFT = fft2(double(img));
    imgFFTShifted = fftshift(imgFFT); % Shift zero frequency to center
    magnitudeSpectrum = log(1 + abs(imgFFTShifted));

    % Plot the original image and the magnitude spectrum
    figure;
    subplot(2, 2, 1);
    imshow(img, []);
    title('Original Image');

    subplot(2, 2, 2);
    imshow(magnitudeSpectrum, []);
    title('Magnitude Spectrum');

    % Step 3: Analyze the magnitude spectrum to find the dominant orientation
    % Sum the magnitude spectrum along rows and columns
    sumHorizontal = sum(magnitudeSpectrum, 1);
    sumVertical = sum(magnitudeSpectrum, 2);

    % Find the indices of the maximum values in the summed spectra
    [~, idxHorizontal] = max(sumHorizontal);
    [~, idxVertical] = max(sumVertical);

    % Calculate the angle of the dominant frequency component
    centerX = size(magnitudeSpectrum, 2) / 2;
    centerY = size(magnitudeSpectrum, 1) / 2;

    % Calculate the angle in degrees
    angleX = atan2d(idxVertical - centerY, centerX);
    angleY = atan2d(centerY, idxHorizontal - centerX);

    % Average the two angles for robustness
    detectedAngle = mean([angleX, angleY]);
    fprintf('Detected angle of the barcode: %f degrees\n', detectedAngle);

    % Step 4: Rotate the image to make the barcode horizontal
    rotatedImg = imrotate(img, -detectedAngle, 'bilinear', 'crop');
    preprocessedImg = rotatedImg;

    % Display the rotated image
    subplot(2, 2, 3);
    imshow(rotatedImg, []);
    title(sprintf('Rotated Image (Angle: %f degrees)', detectedAngle));

    % Plot the summed spectra
    subplot(2, 2, 4);
    hold on;
    plot(sumHorizontal);
    plot(sumVertical);
    title('Summed Magnitude Spectra');
    xlabel('Frequency Index');
    ylabel('Summed Magnitude');
    legend('Horizontal Sum', 'Vertical Sum');
    hold off;
end