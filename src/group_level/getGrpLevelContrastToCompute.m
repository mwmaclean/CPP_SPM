% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function [grpLvlCon, iStep] = getGrpLevelContrastToCompute(opt)
  %
  % Returns the autocontrast part of the dataset step of the BIDS model
  %
  % USAGE::
  %
  %   function [grpLvlCon, iStep] = getGrpLevelContrastToCompute(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % :returns: - :grpLvlCon:
  %           - :iStep:
  %

  model = spm_jsonread(opt.model.file);

  for iStep = 1:length(model.Steps)
    if strcmp(model.Steps{iStep}.Level, 'dataset')
      grpLvlCon = model.Steps{iStep}.AutoContrasts;
      break
    end
  end

end
