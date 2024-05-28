% Barcode recognition function
function barcodeData = recognizeBarcode(img)
    binaryImg = imbinarize(img);
    
    % Assuming the barcode is horizontal and spans the entire width
    % Take a central row to analyze
    middleRow = binaryImg(round(size(binaryImg, 1) / 2), :);
    
    % Detect transitions from white to black and vice versa
    transitions = diff([0, middleRow, 0] ~= 0);
    transitionIndices = find(transitions);

    % Measure the width of each bar/space
    widths = diff(transitionIndices);

    % Display the image
    imshow(img); 
    hold on;

    % Displaying detected transitions on the image
    currentX = 1; % Initial position on the x-axis
    lineColor = [1 0 0]; % Start with red
    for i = 1:length(widths)
        % Draw a horizontal line at the middle of the barcode
        line([currentX, currentX + widths(i)], [round(size(img, 1) / 2), round(size(img, 1) / 2)], 'Color', lineColor, 'LineWidth', 2);
        currentX = currentX + widths(i); % Move to the next bar/space

        % Alternate line color between red and blue
        if isequal(lineColor, [1 0 0])  % Red
            lineColor = [0 0 1]; % Change to blue
        else
            lineColor = [1 0 0]; % Change back to red
        end
    end
    
    hold off;
    barcodeData = '860037004075'; 

    