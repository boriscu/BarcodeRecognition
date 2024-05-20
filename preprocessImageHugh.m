function preprocessedImg = preprocessImageHugh(img, showPlots)
    % Step 1: Convert the image to grayscale
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Detect the angle of the barcode lines using Hough transform
    edges = edge(img, 'Canny');
    [H, theta, rho] = hough(edges);
    peaks = houghpeaks(H, 5);
    lines = houghlines(edges, theta, rho, peaks);

    if showPlots
        figure;
        % Subplot 1: Original grayscale image with detected lines
        subplot(1,2,1);
        imshow(img);
        hold on;
        max_len = 0;
        angles = [];
        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
            plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
            plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
            lineAngle = atan2d(xy(2,2) - xy(1,2), xy(2,1) - xy(1,1));
            angles = [angles, lineAngle];
            len = norm(lines(k).point1 - lines(k).point2);
            if (len > max_len)
                max_len = len;
                xy_long = xy;
            end
        end
        plot(xy_long(:,1), xy_long(:,2), 'LineWidth', 2, 'Color', 'cyan');
        title('Original Image with Detected Lines');
        hold off;
    end

    % Calculate the most frequent angle
    angleHistogram = histcounts(angles, -90:90);
    [~, maxIdx] = max(angleHistogram);
    detectedAngle = maxIdx - 1;

    % Rotate the image to make the barcode horizontal
    rotatedImg = imrotate(img, detectedAngle, 'bilinear', 'crop');
    preprocessedImg = rotatedImg;

    if showPlots
        % Subplot 2: Rotated image
        subplot(1,2,2);
        imshow(rotatedImg, []);
        title(sprintf('Rotated Image (Angle: %f degrees)', detectedAngle));
    end
end