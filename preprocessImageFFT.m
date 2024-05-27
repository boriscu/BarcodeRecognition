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
    
    originalFFT = fft2(double(img));
    originalFFTShifted = fftshift(originalFFT);
    originalMagnitudeSpectrum = abs(originalFFTShifted);

    % Applying a threshold to focus on significant peaks
    thresholdLevel = 0.5 * max(magnitudeSpectrum(:));
    significantPeaks = magnitudeSpectrum > thresholdLevel;

    % Display results if needed
    if showPlots
        figure;
        subplot(2, 4, 1);
        imshow(img, []);
        title('Original Image');

        subplot(2, 4, 2);
        imshow(log(1 + originalMagnitudeSpectrum), []);
        title('Original Magnitude Spectrum');
        
        subplot(2, 4, 3);
        freqz2(h); 
        title('Filter Frequency Response');

        subplot(2, 4, 4);
        imshow(highPassImg, []);
        title('High-Pass Filtered Image');    
        
        subplot(2, 4, 5);
        imshow(log(1 + magnitudeSpectrum), []);
        title('Filtered Magnitude Spectrum');

        subplot(2, 4, 6);
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
        subplot(2, 4, 7);
        imshow(rotatedImg, []);
        title(sprintf('Rotated Image (Angle: %f degrees)', principalAngleDegrees));
    end
end
