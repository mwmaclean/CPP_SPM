function test_suite = test_setBatchSubjectLevelContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSubjectLevelContrastsBasic()

  subID = '01';
  funcFWHM = 6;

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.space = 'MNI';
  opt.taskName = 'vismotion';
  opt.model.file = ...
      fullfile(fileparts(mfilename('fullpath')), ...
               'dummyData', ...
               'models', ...
               'model-visMotionLoc_smdl.json');

  opt = setDerivativesDir(opt);
  opt = checkOptions(opt);

  matlabbatch = [];
  matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subID, funcFWHM);

  expectedBatch = [];
  expectedBatch{end + 1}.spm.stats.con.spmmat = {fullfile(opt.derivativesDir, ...
                                                          'sub-01', ...
                                                          'stats', ...
                                                          'ffx_task-vismotion', ...
                                                          'ffx_space-MNI_FWHM-6', ...
                                                          'SPM.mat')};
  expectedBatch{end}.spm.stats.con.delete = 1;

  consess{1}.tcon.name = 'VisMot'; %#ok<*AGROW>
  consess{1}.tcon.convec = [1 0 0 0 0 0 0 0 0];
  consess{1}.tcon.sessrep = 'none';

  consess{2}.tcon.name = 'VisStat'; %#ok<*AGROW>
  consess{2}.tcon.convec = [0 1 0 0 0 0 0 0 0];
  consess{2}.tcon.sessrep = 'none';

  consess{3}.tcon.name = 'VisMot_gt_VisStat'; %#ok<*AGROW>
  consess{3}.tcon.convec = [1 -1 0 0 0 0 0 0 0];
  consess{3}.tcon.sessrep = 'none';

  consess{4}.tcon.name = 'VisStat_gt_VisMot'; %#ok<*AGROW>
  consess{4}.tcon.convec = [-1 1 0 0 0 0 0 0 0];
  consess{4}.tcon.sessrep = 'none';

  expectedBatch{end}.spm.stats.con.consess = consess;

  assertEqual(matlabbatch{1}.spm.stats.con, expectedBatch{1}.spm.stats.con);

end
