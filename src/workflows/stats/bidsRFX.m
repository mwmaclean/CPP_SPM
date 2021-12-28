function bidsRFX(action, opt)
  %
  % - smooths all contrast images created at the subject level
  %
  % OR
  %
  % - creates a mean structural image and mean mask over the sample
  %
  % OR
  %
  % - specifies and estimates the group level model,
  % - computes the group level contrasts.
  %
  % USAGE::
  %
  %  bidsRFX(action, opt)
  %
  % :param action: Action to be conducted: ``'smoothContrasts'`` or ``'RFX'`` or
  %                ``'meanAnatAndMask'``
  % :type action: string
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  checks(opt, action);

  opt = mniToIxi(opt);

  [~, opt] = setUpWorkflow(opt, 'group level GLM');

  matlabbatch = {};

  switch lower(action)

    case 'smoothcontrasts'

      matlabbatch = setBatchSmoothConImages(matlabbatch, opt);

      saveAndRunWorkflow(matlabbatch, ...
                         ['smooth_con_FWHM-', num2str(opt.fwhm.contrast), ...
                          '_task-', strjoin(opt.taskName, '')], ...
                         opt);

    case 'meananatandmask'

      % TODO
      % - need to rethink where to save the anat and mask
      % - need to smooth the anat
      % - create a masked version of the anat too

      opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats');
      opt.dir.jobs = fullfile(opt.dir.output, 'jobs',  strjoin(opt.taskName, ''));

      matlabbatch = setBatchMeanAnatAndMask(matlabbatch, ...
                                            opt, ...
                                            opt.dir.output);
      saveAndRunWorkflow(matlabbatch, 'create_mean_struc_mask', opt);

    case 'rfx'

      opt.dir.output = fullfile(opt.dir.stats, 'derivatives', 'cpp_spm-groupStats');
      opt.dir.jobs = fullfile(opt.dir.output, 'jobs',  strjoin(opt.taskName, ''));

      matlabbatch = setBatchFactorialDesign(matlabbatch, opt);

      grpLvlCon = getGrpLevelContrast(opt);
      matlabbatch = setBatchEstimateModel(matlabbatch, opt, grpLvlCon);
      saveAndRunWorkflow(matlabbatch, 'group_level_model_specification_estimation', opt);

      % add basic BIDS dataset info
      initBIDS(opt);

      rfxDir = getRFXdir(opt);

      matlabbatch = {};
      matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, grpLvlCon, rfxDir);
      saveAndRunWorkflow(matlabbatch, 'contrasts_rfx', opt);

  end

end

function checks(opt, action)

  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    errorHandling(mfilename(), 'tooManySpaces', msg, false, opt.verbosity);
  end

  allowedActions = {'smoothcontrasts', 'meananatandmask', 'rfx'};
  if ~ismember(lower(action), allowedActions)
    msg = sprintf('action must be: %s.\n%s was given.', createUnorderedList(allowedActions), ...
                  action);
    errorHandling(mfilename(), 'unknownAction', msg, false, opt.verbosity);
  end

end

function initBIDS(opt)

  descr_file = fullfile(opt.dir.output, 'dataset_description.json');
  if ~exist(descr_file, 'file')
    isDerivative = true;
    bids.init(opt.dir.output, struct(), isDerivative);
    ds_desc = bids.Description('cpp_spm-groupStats');
    ds_desc.content.BIDSVersion = '1.6.0';
    ds_desc.content.GeneratedBy{1}.Version = getVersion();
    ds_desc.content.GeneratedBy{1}.CodeURL = getRepoURL();
    ds_desc.content.GeneratedBy{1}.Description = 'group level statistics';
    ds_desc.write(opt.dir.output);
  end

end
