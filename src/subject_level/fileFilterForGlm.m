function [filter, opt] = fileFilterForGlm(opt, subLabel)
  %
  % USAGE::
  %
  %  [filter, opt] = fileFilterForGlm(opt)
  %
  % (C) Copyright 2022 CPP_SPM developers

  opt.query.modality = 'func';

  if opt.fwhm.func > 0
    opt.query.desc = ['smth' num2str(opt.fwhm.func)];
  else
    opt.query.desc = 'preproc';
  end

  opt.query.space = opt.space;
  opt = mniToIxi(opt);

  % task details are passed in opt.query
  filter = opt.bidsFilterFile.bold;
  filter.prefix =  '';
  filter.sub =  regexify(subLabel);
  filter.extension = {'.nii.*'};

  % use the extra query options specified in the options
  filter = setFields(filter, opt.query);
  filter = removeEmptyQueryFields(filter);
  
  % in case task was not passed through opt.query
  if ~isfield(filter, 'task')
    filter.task = opt.taskName;
  end

end


