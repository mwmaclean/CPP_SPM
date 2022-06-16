function boldFilename = getBoldFilenameForFFX(varargin)
  %
  % Gets the filename for this bold run for this task for the FFX setup
  % and check that the file with the right prefix exist
  %
  % USAGE::
  %
  %   boldFilename = getBoldFilenameForFFX(BIDS, opt, subLabel, funcFWHM, iSes, iRun)
  %
  % :param BIDS:
  % :type BIDS: structure
  %
  % :param opt:
  % :type opt: structure
  %
  % :param subLabel:
  % :type subLabel: string
  %
  % :param iSes:
  % :type iSes: integer
  %
  % :param iRun:
  % :type iRun: integer
  %
  % :returns: - :boldFilename: (string)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  [BIDS, opt, subLabel, iSes, iRun] =  deal(varargin{:});

  [filter, opt] = fileFilterForBold(opt, subLabel);

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  filter.ses = sessions{iSes};

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});
  filter.run = runs{iRun};

  boldFilename = bids.query(BIDS, 'data', filter);

  if numel(boldFilename) > 1
    disp(boldFilename);
    errorHandling(mfilename(), 'tooManyFiles', 'This should only get one file.', false, true);
  elseif isempty(boldFilename)
    msg = sprintf('No bold file found in:\n\t%s\nfor query:%s\n', ...
                  BIDS.pth, ...
                  createUnorderedList(opt.query));
    errorHandling(mfilename(), 'noFileFound', msg, false, true);
  end

  % in case files have been unzipped, we do it now
  fullPathBoldFilename = unzipAndReturnsFullpathName(boldFilename{1}, opt);

  printToScreen('\n  Bold file(s):', opt);
  printToScreen(createUnorderedList(pathToPrint(fullPathBoldFilename)), opt);

  boldFilename = spm_file(fullPathBoldFilename, 'filename');
  subFuncDataDir = spm_file(fullPathBoldFilename, 'path');

  boldFilename = fullfile(subFuncDataDir, boldFilename);

end
