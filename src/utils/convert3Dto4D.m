% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function convert3Dto4D
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % .. todo:
  %
  %    - expand to run through multiple subjs ans groups
  %      (https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files)
  %    - generalize how to retrieve RT from sidecar json file
  %    - saveMatlabBatch(matlabbatch, ['3Dto4D_dataType-' num2str(dataType) '_RT-' num2str(RT)], opt, subID);

  % Set the folder where sequences folders exist
  optSource.sourceDir = '/Users/barilari/Desktop/DICOM_UCL_leuven/renamed/sub-pilot001/ses-002/MRI';

  % List the sequences that you want to skip (folder name pattern)
  optSource.sequenceToIgnore = {'AAHead_Scout', ...
                                'b1map', ...
                                't1', ...
                                'gre_field'};

  % Set data format conversion (0 is reccomended)

  % 0:  SAME
  % 2:  UINT8   - unsigned char
  % 4:  INT16   - signed short
  % 8:  INT32   - signed int
  % 16: FLOAT32 - single prec. float
  % 64: FLOAT64 - double prec. float
  dataType = 0;

  % Get source folder content
  sourceDataStruc = dir(optSource.sourceDir);

  isDir = [sourceDataStruc(:).isdir];

  optSource.sequenceList = {sourceDataStruc(isDir).name}';

  % Loop through the sequence folders

  tic;

  for iSeq = 1:size(optSource.sequenceList, 1)

    % Skip 'non' folders
    if length(char(optSource.sequenceList(iSeq))) > 2

      % Check if sequence to ignore or not
      if contains(optSource.sequenceList(iSeq), optSource.sequenceToIgnore)

        newline;
        warning('IGNORING SEQUENCE: %s', string(optSource.sequenceList(iSeq)));
        newline;

      else

        fprintf('\n\nCONVERTING SEQUENCE: %s \n\n', char(optSource.sequenceList(iSeq)));

        % Get sequence folder path
        sequencePath = char(fullfile(optSource.sourceDir, optSource.sequenceList(iSeq)));

        % Retrieve volume files info
        [volumesList, outputNameImage] = parseNiiFiles(sequencePath);

        % Set output name, it takes the file name of the first volume and add subfix '_4D'
        %             outputName = char(volumesToConvert(1).name);

        dotPos = find(outputNameImage == '.');

        outputNameImage = outputNameImage(1:dotPos(1) - 1);

        outputNameImage = [outputNameImage '_4D.nii']; %#ok<AGROW>

        % Retrieve sidecar json files info
        [jsonList, outputNameJson] = parseJsonFiles(sequencePath);

        jsonFile = jsondecode(fileread(char(jsonList(1))));

        % % % % % % LIEGE  SPECIFIC % % % % % % %
        RT = jsonFile.acqpar.RepetitionTime / 1000;
        % % % % % % % % % % % % % % % % % % % % %

        % Set and run spm batch
        matlabbatch = setBatch3Dto4D(volumesList, outputNameImage, dataType, RT);

        spm_jobman('run', matlabbatch);

        % Zip and delete the and the new 4D file
        fprintf(1, 'ZIP AND DELETE THE NEW 4D BRAIN \n\n');

        gzip([sequencePath filesep outputNameImage]);

        delete([sequencePath filesep outputNameImage]);

        % Save one sidecar json file, it takes the first volume one and add subfix '_4D'
        dotPos = find(char(outputNameJson) == '.');

        %             jsonCopy = char(jsonList(1));

        outputNameJson = outputNameJson(1:dotPos(1) - 1);

        if ~isempty(jsonList)

          copyfile(char(jsonList(1)), [sequencePath filesep outputNameJson '_4D.json']);

        end

        % Delete all the single volumes .nii and .json files
        fprintf(1, 'EXTERMINATE SINGLE VOLUMES FILES \n\n');

        for iDel = 1:length(volumesList)

          delete(char(volumesList(iDel)));
          delete(char(jsonList(iDel)));

        end

      end

    end

  end

  newline;
  toc;

end

function [volumesList, outputNameImage] = parseNiiFiles(sequencePath)

  volumesList = spm_select('list', sequencePath, 'nii');

  outputNameImage = volumesList(1, :);

  volumesList = strcat(sequencePath, filesep, cellstr(volumesList));

end

function [jsonList, outputNameJson] = parseJsonFiles(sequencePath)

  jsonList = spm_select('list', sequencePath, 'json');

  if size(jsonList, 1) > 0

    outputNameJson = jsonList(1, :);

    jsonList = strcat(sequencePath, filesep, cellstr(jsonList));

  else

    jsonList = {};

    outputNameJson = [];

  end

end
