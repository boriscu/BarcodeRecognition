function preprocessedImg = preprocessImageFFT(img, showPlots)
    % Convert the image to grayscale if not already
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % High-pass filter to enhance edges
    hpfSize = 15;  % Size of the averaging filter
    h = fspecial('average', hpfSize);
    lowPassImg = imfilter(double(img), h, 'replicate');
    highPassImg = double(img) - lowPassImg;

    % Compute the FFT of the high-pass filtered image
    imgFFT = fft2(highPassImg);
    imgFFTShifted = fftshift(imgFFT);
    magnitudeSpectrum = abs(imgFFTShifted);

    % Applying a threshold to focus on significant peaks
    thresholdLevel = 0.5 * max(magnitudeSpectrum(:));
    significantPeaks = magnitudeSpectrum > thresholdLevel;

    % Display results if needed
    if showPlots
        figure;
        subplot(2, 3, 1);
        imshow(img, []);
        title('Original Image');

        subplot(2, 3, 2);
        imshow(log(1 + magnitudeSpectrum), []);
        title('Magnitude Spectrum');

        subplot(2, 3, 3);
        imshow(log(1 + magnitudeSpectrum .* significantPeaks), []);
        title('Significant Peaks');
    end

    % Get coordinates of significant peaks
    [peakRows, peakCols] = find(significantPeaks);
    peaks = [peakCols, peakRows]; % Note: x (cols), y (rows) for PCA

    % Apply PCA to find the orientation of the line that fits these points
    if size(peaks, 1) > 1 % Ensure there are enough points for PCA
        coeff = pca(peaks);
        principalAngleRadians = atan2(coeff(2, 1), coeff(1, 1));
        principalAngleDegrees = rad2deg(principalAngleRadians);
    else
        principalAngleDegrees = 0; % Default angle if not enough points
    end

    fprintf('Detected angle of the barcode: %f degrees\n', principalAngleDegrees);

    % Rotate the image to make the barcode horizontal
    rotatedImg = imrotate(img, principalAngleDegrees, 'bilinear', 'crop');
    preprocessedImg = rotatedImg;

    if showPlots
        subplot(2, 3, 4);
        imshow(rotatedImg, []);
        title(sprintf('Rotated Image (Angle: %f degrees)', principalAngleDegrees));
    end
end
