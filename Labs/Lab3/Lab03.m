% ----------------------------------------------------------------------- %
% CITS4402 Lab03 Week04                                                   %
% Author: Farshad Ghanbari                                                %
% Student Number: 21334883                                                %
% ----------------------------------------------------------------------- %

classdef wk04lab03 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        Panel_2                  matlab.ui.container.Panel
        WarningField             matlab.ui.control.EditField
        SigmaEditFieldLabel      matlab.ui.control.Label
        SigmaEditField           matlab.ui.control.NumericEditField
        SizeEditFieldLabel       matlab.ui.control.Label
        SizeEditField            matlab.ui.control.NumericEditField
        FactorEditFieldLabel     matlab.ui.control.Label
        FactorEditField          matlab.ui.control.NumericEditField
        HighBoostButton          matlab.ui.control.Button
        HighPassButton           matlab.ui.control.Button
        LowPassButton            matlab.ui.control.Button
        HistogramEqualizeButton  matlab.ui.control.Button
        Panel                    matlab.ui.container.Panel
        LoadImageButton          matlab.ui.control.Button
        UIAxes_Filtered          matlab.ui.control.UIAxes
        UIAxes_Original          matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        original_image
        filtered_image
    end
    
    methods (Access = private)

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        % Setting default values for tunable parameters
        function startupFcn(app)
            app.SigmaEditField.Value = 2;
            app.SizeEditField.Value = 3;
            app.FactorEditField.Value = 2;
        end

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, ~)
            % Clears any previous warning text
            app.WarningField.Visible = 'off';

            % Opens a dialog box in the current folder.
            % User then is able to select an image.
            [fileName,pathName] = uigetfile({'*.png';'*.jpg'; '*.jpeg'},'Choose an Image (.png or .jpg');

            % If no file was selected do nothing.
            % Otherwise store the selected image.
            if not(isequal(fileName, 0))
                try
                    % Clear previous picture and title
                    cla(app.UIAxes_Filtered);
                    app.UIAxes_Filtered.Title.String = '';

                    % Read and store the selected image
                    % Plot the image on the left axis
                    app.original_image = imread(fullfile(pathName, fileName));
                    imshow(app.original_image, 'parent', app.UIAxes_Original);
                catch
                    % Outputs an error message if there was a problem
                    app.WarningField.Value = 'Could not load the selected image. Please try again.';
                    app.WarningField.Visible = 'on';
                end
            end
        end

        % Button pushed function: HistogramEqualizeButton
        function HistogramEqualizeButtonPushed(app, ~)

            % If no image has been selected yet, outputs an error message
            if isempty(app.original_image)
                app.WarningField.Value = 'No image detected. Please load an image to perform histogram equalization';
                app.WarningField.Visible = 'on';
            else
                % Enhances contrast using histogram equaliation.
                % Plot the enhanced image on the right axis.
                app.filtered_image = histeq(app.original_image);
                imshow(app.filtered_image, 'parent', app.UIAxes_Filtered);
                app.UIAxes_Filtered.Title.String = 'Histogram Equalized';
            end
        end

        % Button pushed function: LowPassButton
        function LowPassButtonPushed(app, ~)
            % Extract the tunable parameters entered by the user
            size = app.SizeEditField.Value;
            sigma = app.SigmaEditField.Value;

            % If no image has been selected yet, outputs an error message
            if isempty(app.original_image)
                app.WarningField.Value = 'No image detected. Please load an image to apply low pass filter';
                app.WarningField.Visible = 'on';

            % If size value is an even number, outputs an error message
            elseif (rem(size, 2) == 0)
                app.WarningField.Value = 'Size must be an odd number.';
                app.WarningField.Visible = 'on';

            % If size value is negative, outputs an error message
            elseif (sigma <= 0)
                app.WarningField.Value = 'Size must be a positive number.';
                app.WarningField.Visible = 'on';
            else
                % Otherwise, clear any error messages
                app.WarningField.Visible = 'off';

                % Use a 2D gaussian filter to blur/lowpassfilter the image
                % Plots the filtered image on the right axis.
                app.filtered_image = imgaussfilt(app.original_image, sigma, 'Filtersize', size);
                imshow(app.filtered_image, 'parent', app.UIAxes_Filtered);
                app.UIAxes_Filtered.Title.String = 'Low Pass Filtered';
            end
        end

        % Button pushed function: HighPassButton
        function HighPassButtonPushed(app, ~)
            
            % If no image has been selected yet, outputs an error message
            if isempty(app.original_image)
                app.WarningField.Value = 'No image detected. Please load an image to apply high pass filter';
                app.WarningField.Visible = 'on';
            else
                % Otherwise, clear any error messages
                app.WarningField.Visible = 'off';
                
                % Uses a fix value for sigma (10) to lowpassfilter the
                % image using guassian filter.
                img_low_pass = imgaussfilt(app.original_image, 10);
                
                % Performs highpassfilter via original image -
                % lowpassfiltered image
                % Plots the filtered image in the right axis
                app.filtered_image = app.original_image - img_low_pass;
                imshow(app.filtered_image, 'parent', app.UIAxes_Filtered);
                app.UIAxes_Filtered.Title.String = 'High Pass Filtered';
            end
        end

        % Button pushed function: HighBoostButton
        function HighBoostButtonPushed(app, ~)

            % If no image has been selected yet, outputs an error message
            if isempty(app.original_image)
                app.WarningField.Value = 'No image detected. Please load an image to apply high boost filter';
                app.WarningField.Visible = 'on';

            % If boosting factor entered is negative, outputs an error
            % message
            elseif (app.FactorEditField.Value <= 0)
                app.WarningField.Value = 'Boosting factor must be >= 1';
                app.WarningField.Visible = 'on';
            else
                % Otherwise, clear any error messages
                app.WarningField.Visible = 'off';

                % Performs a highpassfilter as before
                img_low_pass = imgaussfilt(app.original_image, 10);
                img_high_pass = app.original_image - img_low_pass;

                % Highboost filter operation formula
                app.filtered_image = (app.FactorEditField.Value - 1) * app.original_image + img_high_pass;
                imshow(app.filtered_image, 'parent', app.UIAxes_Filtered);
                app.UIAxes_Filtered.Title.String = 'High Boost Filtered';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.1294 0.1451 0.1608];
            app.UIFigure.Position = [100 100 814 619];
            app.UIFigure.Name = 'MATLAB App';

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.BackgroundColor = [0.8706 0.8863 0.902];
            app.Panel.Position = [12 255 792 351];

            % Create UIAxes_Original
            app.UIAxes_Original = uiaxes(app.Panel);
            title(app.UIAxes_Original, 'Original Image')
            app.UIAxes_Original.XTick = [];
            app.UIAxes_Original.YTick = [];
            app.UIAxes_Original.Visible = 'off';
            app.UIAxes_Original.Position = [33 1 336 351];

            % Create UIAxes_Filtered
            app.UIAxes_Filtered = uiaxes(app.Panel);
            title(app.UIAxes_Filtered, 'Title')
            app.UIAxes_Filtered.XTick = [];
            app.UIAxes_Filtered.YAxisLocation = 'right';
            app.UIAxes_Filtered.YTick = [];
            app.UIAxes_Filtered.Visible = 'off';
            app.UIAxes_Filtered.Position = [457 1 336 351];

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.Panel, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.BackgroundColor = [0.2039 0.2275 0.251];
            app.LoadImageButton.FontColor = [0.9137 0.9255 0.9373];
            app.LoadImageButton.Position = [346 23 100 44];
            app.LoadImageButton.Text = 'Load Image';

            % Create Panel_2
            app.Panel_2 = uipanel(app.UIFigure);
            app.Panel_2.BackgroundColor = [0.8078 0.8314 0.8549];
            app.Panel_2.Position = [12 15 792 233];

            % Create HistogramEqualizeButton
            app.HistogramEqualizeButton = uibutton(app.Panel_2, 'push');
            app.HistogramEqualizeButton.ButtonPushedFcn = createCallbackFcn(app, @HistogramEqualizeButtonPushed, true);
            app.HistogramEqualizeButton.BackgroundColor = [0.2039 0.2275 0.251];
            app.HistogramEqualizeButton.FontColor = [0.9137 0.9255 0.9373];
            app.HistogramEqualizeButton.Position = [336 171 120 45];
            app.HistogramEqualizeButton.Text = 'Histogram Equalize';

            % Create LowPassButton
            app.LowPassButton = uibutton(app.Panel_2, 'push');
            app.LowPassButton.ButtonPushedFcn = createCallbackFcn(app, @LowPassButtonPushed, true);
            app.LowPassButton.BackgroundColor = [0.2039 0.2275 0.251];
            app.LowPassButton.FontColor = [0.9137 0.9255 0.9373];
            app.LowPassButton.Position = [119 105 100 35];
            app.LowPassButton.Text = 'Low Pass';

            % Create HighPassButton
            app.HighPassButton = uibutton(app.Panel_2, 'push');
            app.HighPassButton.ButtonPushedFcn = createCallbackFcn(app, @HighPassButtonPushed, true);
            app.HighPassButton.BackgroundColor = [0.2039 0.2275 0.251];
            app.HighPassButton.FontColor = [0.9137 0.9255 0.9373];
            app.HighPassButton.Position = [346 105 100 35];
            app.HighPassButton.Text = 'High Pass';

            % Create HighBoostButton
            app.HighBoostButton = uibutton(app.Panel_2, 'push');
            app.HighBoostButton.ButtonPushedFcn = createCallbackFcn(app, @HighBoostButtonPushed, true);
            app.HighBoostButton.BackgroundColor = [0.2039 0.2275 0.251];
            app.HighBoostButton.FontColor = [0.9137 0.9255 0.9373];
            app.HighBoostButton.Position = [575 105 100 35];
            app.HighBoostButton.Text = 'High Boost';

            % Create FactorEditField
            app.FactorEditField = uieditfield(app.Panel_2, 'numeric');
            app.FactorEditField.FontWeight = 'bold';
            app.FactorEditField.BackgroundColor = [0.9137 0.9255 0.9373];
            app.FactorEditField.Position = [639 76 36 22];

            % Create FactorEditFieldLabel
            app.FactorEditFieldLabel = uilabel(app.Panel_2);
            app.FactorEditFieldLabel.HorizontalAlignment = 'right';
            app.FactorEditFieldLabel.FontWeight = 'bold';
            app.FactorEditFieldLabel.Position = [573 76 42 22];
            app.FactorEditFieldLabel.Text = 'Factor';

            % Create SizeEditField
            app.SizeEditField = uieditfield(app.Panel_2, 'numeric');
            app.SizeEditField.FontWeight = 'bold';
            app.SizeEditField.BackgroundColor = [0.9137 0.9255 0.9373];
            app.SizeEditField.Position = [183 76 36 22];

            % Create SizeEditFieldLabel
            app.SizeEditFieldLabel = uilabel(app.Panel_2);
            app.SizeEditFieldLabel.HorizontalAlignment = 'right';
            app.SizeEditFieldLabel.FontWeight = 'bold';
            app.SizeEditFieldLabel.Position = [129 76 30 22];
            app.SizeEditFieldLabel.Text = 'Size';

            % Create SigmaEditField
            app.SigmaEditField = uieditfield(app.Panel_2, 'numeric');
            app.SigmaEditField.FontWeight = 'bold';
            app.SigmaEditField.BackgroundColor = [0.9137 0.9255 0.9373];
            app.SigmaEditField.Position = [183 46 36 22];

            % Create SigmaEditFieldLabel
            app.SigmaEditFieldLabel = uilabel(app.Panel_2);
            app.SigmaEditFieldLabel.HorizontalAlignment = 'right';
            app.SigmaEditFieldLabel.FontWeight = 'bold';
            app.SigmaEditFieldLabel.Position = [117 46 42 22];
            app.SigmaEditFieldLabel.Text = 'Sigma';

            % Create WarningField
            app.WarningField = uieditfield(app.Panel_2, 'text');
            app.WarningField.Editable = 'off';
            app.WarningField.HorizontalAlignment = 'center';
            app.WarningField.FontWeight = 'bold';
            app.WarningField.FontColor = [0.8392 0.1569 0.1569];
            app.WarningField.BackgroundColor = [0.9137 0.9255 0.9373];
            app.WarningField.Visible = 'off';
            app.WarningField.Position = [10 14 772 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = wk04lab03

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

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