function bidsLesionAbnormalitiesDetection(opt)
  %
  % Use the ALI toolbox to detect lesion abnormalities in anatomical image
  % after segmentation of the image.
  %
  % Requires the ALI toolbox: https://doi.org/10.3389/fnins.2013.00241
  %
  % USAGE::
  %
  %  bidsLesionAbnormalitiesDetection(opt)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % Lesion abnormalities detection will be performed using the information provided
  % from the lesion segmentation output in BIDS format.
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  opt.dir.input = opt.dir.preproc;

  if checkToolbox('ALI', 'verbose', opt.verbosity > 0)
    opt = setFields(opt, ALI_my_defaults());
  end

  [BIDS, opt] = setUpWorkflow(opt, 'abnormalities detection');

  labels = {'GM', 'WM'};

  % create a structure to collect image names
  for i = 1:numel(labels)
    images(i, 1) = struct('controls', [], 'patients', []);
  end

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    idx = strcmp(BIDS.participants.content.participant_id, ['sub-' subLabel]);
    if isfield(BIDS.participants.content, 'group')
      participantsGroup = BIDS.participants.content.group(idx);
    elseif isfield(BIDS.participants.content, 'Group')
      participantsGroup = BIDS.participants.content.Group(idx);
    end

    anatImage = getAnatFilename(BIDS, opt, subLabel);
    anatImage = bids.File(anatImage);
    filter = anatImage.entities;
    filter.modality = 'anat';
    filter.suffix = 'probseg';

    fwhm = opt.toolbox.ALI.unified_segmentation.step1fwhm;
    filter.desc = ['smth' num2str(fwhm)];

    for i = 1:numel(labels)

      filter.label = labels{i};
      files = bids.query(BIDS, 'data', filter);

      if numel(files) > 1
        disp(files);
        tolerant =  false;
        msg = sprintf('Too many files for label %s for subject %s', labels{i}, subLabel);
        id = 'tooManyTissueClassFiles';
        errorHandling(mfilename(), id, msg, tolerant);
      end

      % TODO avoid the hard coding of 'control' :
      % this should probably be in the opt
      if strcmp (participantsGroup, 'control')
        images(i, 1).controls{end + 1, 1} = files{1};
      else
        images(i, 1).patients{end + 1, 1} = files{1};
      end

    end

  end

  controlsImages = cat(1, images.controls);
  patientsImages = cat(1, images.patients);

  if isempty(controlsImages) || ...
    isempty(patientsImages) || ...
    any(cellfun('isempty', controlsImages)) || ...
      any(cellfun('isempty', patientsImages))
    msg = sprintf('Must have segmentation output from patients AND control');
    id = 'missingImages';
    errorHandling(mfilename(), id, msg, false);
  end

  matlabbatch = {};
  matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, opt, images);

  saveAndRunWorkflow(matlabbatch, 'LesionAbnormalitiesDetection', opt);

end
