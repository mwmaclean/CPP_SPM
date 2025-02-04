function test_suite = test_setBatchRealign %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchRealignBasic()

  % TODO
  % need a test with several sessions and runs
  % add test realign and reslice
  % add test realign and unwarp
  % check it returns the right voxDim

  opt.dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'demos', ...
                         'MoAE', 'output', 'MoAEpilot');
  opt.taskName = 'auditory';

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  subID = '01';

  matlabbatch = [];
  matlabbatch = setBatchRealign(matlabbatch, BIDS, opt, subID);

  expectedBatch{1}.spm.spatial.realignunwarp.eoptions.weight = {''};
  expectedBatch{end}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];

  runCounter = 1;
  for iSes = 1
    fileName = spm_BIDS(BIDS, 'data', ...
                        'sub', subID, ...
                        'task', opt.taskName, ...
                        'type', 'bold');

    expectedBatch{end}.spm.spatial.realignunwarp.data(1, iSes).pmscan = { '' };
    expectedBatch{end}.spm.spatial.realignunwarp.data(1, iSes).scans = cellstr(fileName);
  end

  assertEqual(matlabbatch, expectedBatch);

end
