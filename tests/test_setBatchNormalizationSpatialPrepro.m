% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_setBatchNormalizationSpatialPrepro %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchNormalizationSpatialPreproBasic()

  % necessarry to deal with SPM module dependencies
  spm_jobman('initcfg');

  opt.orderBatches.coregister = 3;
  opt.orderBatches.segment = 5;

  matlabbatch = {};
  voxDim = [3 3 3];
  matlabbatch = setBatchNormalizationSpatialPrepro(matlabbatch, opt, voxDim);

  expectedBatch = returnExpectedBatch(voxDim);

  assertEqual(expectedBatch, matlabbatch);

end

function expectedBatch = returnExpectedBatch(voxDim)

  expectedBatch = {};

  jobsToAdd = numel(expectedBatch) + 1;

  for iJob = jobsToAdd:(jobsToAdd + 4)
    expectedBatch{iJob}.spm.spatial.normalise.write.subj.def(1) = ...
        cfg_dep('Segment: Forward Deformations', ...
                substruct( ...
                          '.', 'val', '{}', {5}, ...
                          '.', 'val', '{}', {1}, ...
                          '.', 'val', '{}', {1}), ...
                substruct('.', 'fordef', '()', {':'})); %#ok<*AGROW>

  end

  expectedBatch{jobsToAdd}.spm.spatial.normalise.write.subj.resample(1) = ...
      cfg_dep('Coregister: Estimate: Coregistered Images', ...
              substruct( ...
                        '.', 'val', '{}', {3}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct('.', 'cfiles'));
  expectedBatch{jobsToAdd}.spm.spatial.normalise.write.woptions.vox = voxDim;

  expectedBatch{jobsToAdd + 1}.spm.spatial.normalise.write.subj.resample(1) = ...
      cfg_dep('Segment: Bias Corrected (1)', ...
              substruct( ...
                        '.', 'val', '{}', {5}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct( ...
                        '.', 'channel', '()', {1}, ...
                        '.', 'biascorr', '()', {':'}));
  expectedBatch{jobsToAdd + 1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];

  expectedBatch{jobsToAdd + 2}.spm.spatial.normalise.write.subj.resample(1) = ...
      cfg_dep('Segment: c1 Images', ...
              substruct( ...
                        '.', 'val', '{}', {5}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct( ...
                        '.', 'tiss', '()', {1}, ...
                        '.', 'c', '()', {':'}));
  expectedBatch{jobsToAdd + 2}.spm.spatial.normalise.write.woptions.vox = voxDim;

  expectedBatch{jobsToAdd + 3}.spm.spatial.normalise.write.subj.resample(1) = ...
      cfg_dep('Segment: c2 Images', ...
              substruct( ...
                        '.', 'val', '{}', {5}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct( ...
                        '.', 'tiss', '()', {2}, ...
                        '.', 'c', '()', {':'}));
  expectedBatch{jobsToAdd + 3}.spm.spatial.normalise.write.woptions.vox = voxDim;

  expectedBatch{jobsToAdd + 4}.spm.spatial.normalise.write.subj.resample(1) = ...
      cfg_dep('Segment: c3 Images', ...
              substruct( ...
                        '.', 'val', '{}', {5}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct( ...
                        '.', 'tiss', '()', {3}, ...
                        '.', 'c', '()', {':'}));
  expectedBatch{jobsToAdd + 4}.spm.spatial.normalise.write.woptions.vox = voxDim;

end
