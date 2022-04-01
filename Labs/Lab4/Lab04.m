% ----------------------------------------------------------------------- %
% CITS4402 Lab04 Week05                                                   %
% Author: Farshad Ghanbari                                                %
% Student Number: 21334883                                                %
% ----------------------------------------------------------------------- %
%{
BUG NOTICE: viscircles function inside my drawCircle function pops an empty
figure for an unknown reason.

DESCRIPTION OF APPROACH:
After an image is loaded, it is converted to gray scale. Both images are
stored in their respective global variables.

There are 6 Detection algorithms to choose from (Sobel, Prewitt, Roberts,
Log, DEFAULT=Canny and approxcanny).

The threshold and circle radius values are obtained directly from the
sliders. The sliders have a default value at the start of the program which
are used if user clicks on detect edge button.

The threshold is used differently for different algorithm. For the
gradient-magnitude edge detection methods (Sobel, Prewitt, and Roberts),
edge uses threshold to threshold the calculated gradient magnitude. For the
zero-crossing methods, such as Laplacian of Gaussian (log), edge uses
threshold as a threshold for the zero-crossings. In other words, a large
jump across zero is an edge, while a small jump is not. For the Canny
method, edge applies tw othresholds to the gradient. A high threshold for
low edge sensitivity and a low threshold for high edge sensitivity. Edge
starts with the low sensitivity result and then grows it to include
connected edge pixels from the high sensitivity. This helps fill in gaps in
the dected edges. So, overall, threshold is used to ignore all  edges that
are not stronger than threshold. It is a sensitivity value to eliminate
insignificant edges.

The edge image is then used to detect and draw circles. Imfindcircles find
circles using circular Hough transform. It first computes and accumulator
array. Foreground pixels of high gradient are designated as being candidate
pixels and are allowed to cast 'votes' in the accumulator array. In a
classical Accumulator Array Computation (CHT), the candidate pixels vote in
pattern around the mthat forms a full circle of a fixed radius. Next, the
centre is estimated. The votes of candidate pixels belonging to an image
circle tend to accumulate at the accumulator array bin corresponding to the
circle's center. Therefore, the circle centers are estimated by detecting
the peaks in the accumulator array. Final radius is estimated. If the same
accumulator array is used for more than one radius value, as is commonly
done in CHT algorithms, radii of the detected circles have to be estimated
as a separate step. Imfindcircles provides two algorithms for finding
circles: phase-coding (default used in this software), and two-stage.

The detected centers and radii are then passed into viscircles function 
which creates and draws the circles.

Source: MathWorks
%}

classdef FarshadGhanbari_21334883_Lab04 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        Panel_2            matlab.ui.container.Panel
        RadiusSlider       matlab.ui.control.Slider
        ApproximateRadiusforCircleDetectionSliderLabel  matlab.ui.control.Label
        ThresholdSlider    matlab.ui.control.Slider
        ThresholdforEdgeDetectionSliderLabel  matlab.ui.control.Label
        Panel              matlab.ui.container.Panel
        WarningField       matlab.ui.control.EditField
        DetectEdgesButton  matlab.ui.control.Button
        DropDown           matlab.ui.control.DropDown
        DetectionAlgorithmDropDownLabel  matlab.ui.control.Label
        LoadImageButton    matlab.ui.control.Button
        ImageContainer     matlab.ui.container.Panel
        UIAxes_Filtered    matlab.ui.control.UIAxes
        UIAxes_Original    matlab.ui.control.UIAxes
    end

    % Global properties
    properties (Access = private)
        original_image
        gray_image
        edge_image
    end
    
    methods (Access = private)
        % Detects and draws the circles using edge_image
        % Called after sliders move or detect edge button is clicked
        function drawCircle(app, radius)
            % Setting a range of values for radius approximation
            min_radius = uint8(radius - 5);
            max_radius = uint8(radius + 5);
            % Setting the minimum value to 6 since imfindcircles is not
            % accurate for values <= 5
            if (min_radius < 6)
                min_radius = 6;
            end
            % Finding circles based on objectpolarity which looks for
            % bright circles within the radius range given.
            % Sensitivity was manually adjusted for best performance in the
            % sample images.
            [centers, radii] = imfindcircles(app.edge_image,[min_radius, max_radius], 'ObjectPolarity', 'bright', 'Sensitivity', 0.92);
            imshow(app.edge_image, 'parent', app.UIAxes_Filtered);
            imshow(app.original_image, 'parent', app.UIAxes_Original);
            % Detected circles are drawn on both filtered and original image
            viscircles(app.UIAxes_Filtered, centers, radii, 'Color', 'y');
            viscircles(app.UIAxes_Original, centers, radii, 'Color', 'y');
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, ~)
            % Clears any previous warning text
            app.WarningField.Visible = 'off';

            % Opens a dialog box in the current folder.
            % User then is able to select an image.
            [fileName,pathName] = uigetfile({'*.png; *.jpg; *.jpeg;'},'Choose an Image (.png, .jpg or .jpeg');

            % If no file was selected do nothing.
            % Otherwise store the selected image.
            if ~(isequal(fileName, 0))
                try
                    % Read and store the selected image
                    % Plot the image on the left axis
                    app.original_image = imread(fullfile(pathName, fileName));
                    imshow(app.original_image, 'parent', app.UIAxes_Original);
                    % Convert image to grayscale for edge detection
                    % Also plots the grayscale next to the original
                    app.gray_image = rgb2gray(app.original_image);
                    imshow(app.gray_image, 'parent', app.UIAxes_Filtered);
                catch
                    % Outputs an error message if there was a problem
                    app.WarningField.Value = 'Could not load the selected image. Please try again.';
                    app.WarningField.Visible = 'on';
                end
            end
        end

        % Button pushed function: DetectEdgesButton
        function DetectEdgesButtonPushed(app, ~)
            % If no image has been selected yet, outputs an error message
            if isempty(app.original_image)
                app.WarningField.Value = 'No image detected. Please load an image to perform edge detection';
                app.WarningField.Visible = 'on';
            else
                % Detect edge using the given algorithm and threshold
                app.edge_image = edge(app.gray_image, app.DropDown.Value, app.ThresholdSlider.Value);
                % Calls the drawCircle function defined earlier
                app.drawCircle(app.RadiusSlider.Value);
            end
        end

        % Value changing function: RadiusSlider
        function RadiusSliderValueChanging(app, event)
            % If we don't have an image, do nothing.
            if ~isempty(app.original_image)
                % Otherwise as the value changes, update the circles.
                changingValue = event.Value;
                app.drawCircle(changingValue);
            end
        end

        % Value changing function: ThresholdSlider
        function ThresholdSliderValueChanging(app, event)
            % If we don't have an image, do nothing.
            if ~isempty(app.original_image)
                % Otherwise as the value changes, update the images and circles.
                changingValue = event.Value;
                % Detect edges with the new threshold
                app.edge_image = edge(app.gray_image, app.DropDown.Value, changingValue);
                % Dectect and draw circles on the updated image
                app.drawCircle(app.RadiusSlider.Value);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0 0.3725 0.451];
            app.UIFigure.Position = [100 100 978 613];
            app.UIFigure.Name = 'MATLAB App';

            % Create ImageContainer
            app.ImageContainer = uipanel(app.UIFigure);
            app.ImageContainer.ForegroundColor = [0 0.0706 0.098];
            app.ImageContainer.TitlePosition = 'centertop';
            app.ImageContainer.Title = 'Finding Circles in Images with Hough Transform';
            app.ImageContainer.BackgroundColor = [0.9137 0.8471 0.651];
            app.ImageContainer.FontWeight = 'bold';
            app.ImageContainer.Position = [9 271 961 333];

            % Create UIAxes_Original
            app.UIAxes_Original = uiaxes(app.ImageContainer);
            app.UIAxes_Original.XTick = [];
            app.UIAxes_Original.YTick = [];
            app.UIAxes_Original.Visible = 'off';
            app.UIAxes_Original.Position = [30 0 466 311];

            % Create UIAxes_Filtered
            app.UIAxes_Filtered = uiaxes(app.ImageContainer);
            app.UIAxes_Filtered.XTick = [];
            app.UIAxes_Filtered.YTick = [];
            app.UIAxes_Filtered.Visible = 'off';
            app.UIAxes_Filtered.Position = [522 0 466 311];

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.TitlePosition = 'centertop';
            app.Panel.BackgroundColor = [0.5804 0.8235 0.7412];
            app.Panel.Position = [10 11 467 251];

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.Panel, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.BackgroundColor = [0 0.0706 0.098];
            app.LoadImageButton.FontColor = [0.9333 0.6078 0];
            app.LoadImageButton.Position = [186 175 100 39];
            app.LoadImageButton.Text = 'Load Image';

            % Create DetectionAlgorithmDropDownLabel
            app.DetectionAlgorithmDropDownLabel = uilabel(app.Panel);
            app.DetectionAlgorithmDropDownLabel.HorizontalAlignment = 'right';
            app.DetectionAlgorithmDropDownLabel.FontWeight = 'bold';
            app.DetectionAlgorithmDropDownLabel.FontColor = [0 0.0706 0.098];
            app.DetectionAlgorithmDropDownLabel.Position = [51 78 120 22];
            app.DetectionAlgorithmDropDownLabel.Text = 'Detection Algorithm';

            % Create DropDown
            app.DropDown = uidropdown(app.Panel);
            app.DropDown.Items = {'Sobel', 'Prewitt', 'Roberts', 'log', 'Canny', 'approxcanny'};
            app.DropDown.FontWeight = 'bold';
            app.DropDown.FontColor = [0.6824 0.1255 0.0706];
            app.DropDown.BackgroundColor = [0.9137 0.8471 0.651];
            app.DropDown.Position = [186 78 100 22];
            app.DropDown.Value = 'Canny';

            % Create DetectEdgesButton
            app.DetectEdgesButton = uibutton(app.Panel, 'push');
            app.DetectEdgesButton.ButtonPushedFcn = createCallbackFcn(app, @DetectEdgesButtonPushed, true);
            app.DetectEdgesButton.BackgroundColor = [0 0.0706 0.098];
            app.DetectEdgesButton.FontColor = [0.9333 0.6078 0];
            app.DetectEdgesButton.Position = [186 106 101 39];
            app.DetectEdgesButton.Text = 'Detect Edges';

            % Create WarningField
            app.WarningField = uieditfield(app.Panel, 'text');
            app.WarningField.Editable = 'off';
            app.WarningField.HorizontalAlignment = 'center';
            app.WarningField.FontWeight = 'bold';
            app.WarningField.FontColor = [0.6824 0.1255 0.0706];
            app.WarningField.BackgroundColor = [0.9137 0.8471 0.651];
            app.WarningField.Visible = 'off';
            app.WarningField.Position = [13 10 443 22];

            % Create Panel_2
            app.Panel_2 = uipanel(app.UIFigure);
            app.Panel_2.BackgroundColor = [0.5804 0.8235 0.7412];
            app.Panel_2.Position = [512 11 459 251];

            % Create ThresholdforEdgeDetectionSliderLabel
            app.ThresholdforEdgeDetectionSliderLabel = uilabel(app.Panel_2);
            app.ThresholdforEdgeDetectionSliderLabel.HorizontalAlignment = 'right';
            app.ThresholdforEdgeDetectionSliderLabel.FontWeight = 'bold';
            app.ThresholdforEdgeDetectionSliderLabel.FontColor = [0 0.0706 0.098];
            app.ThresholdforEdgeDetectionSliderLabel.Position = [129 204 177 22];
            app.ThresholdforEdgeDetectionSliderLabel.Text = 'Threshold for Edge Detection ';

            % Create ThresholdSlider
            app.ThresholdSlider = uislider(app.Panel_2);
            app.ThresholdSlider.Limits = [0 0.99];
            app.ThresholdSlider.ValueChangingFcn = createCallbackFcn(app, @ThresholdSliderValueChanging, true);
            app.ThresholdSlider.FontWeight = 'bold';
            app.ThresholdSlider.FontColor = [0.7333 0.2431 0.0118];
            app.ThresholdSlider.Position = [101 193 245 3];
            app.ThresholdSlider.Value = 0.48;

            % Create ApproximateRadiusforCircleDetectionSliderLabel
            app.ApproximateRadiusforCircleDetectionSliderLabel = uilabel(app.Panel_2);
            app.ApproximateRadiusforCircleDetectionSliderLabel.HorizontalAlignment = 'right';
            app.ApproximateRadiusforCircleDetectionSliderLabel.FontWeight = 'bold';
            app.ApproximateRadiusforCircleDetectionSliderLabel.FontColor = [0 0.0706 0.098];
            app.ApproximateRadiusforCircleDetectionSliderLabel.Position = [96 85 238 22];
            app.ApproximateRadiusforCircleDetectionSliderLabel.Text = 'Approximate Radius for Circle Detection';

            % Create RadiusSlider
            app.RadiusSlider = uislider(app.Panel_2);
            app.RadiusSlider.Limits = [6 50];
            app.RadiusSlider.ValueChangingFcn = createCallbackFcn(app, @RadiusSliderValueChanging, true);
            app.RadiusSlider.FontWeight = 'bold';
            app.RadiusSlider.FontColor = [0.7333 0.2431 0.0118];
            app.RadiusSlider.Position = [100 74 245 3];
            app.RadiusSlider.Value = 26;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = FarshadGhanbari_21334883_Lab04

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end