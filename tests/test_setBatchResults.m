function test_suite = test_setBatchResults %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchResultsBasic()

  iStep = 1;
  iCon = 1;

  result.dir = pwd;
  result.label = '01';
  result.nbSubj = 1;
  result.contrastNb = 1;

  matlabbatch = [];
  matlabbatch = setBatchResults(matlabbatch, result);

  expectedBatch = returnBasicExpectedResultsBatch();

  assertEqual(matlabbatch, expectedBatch);

end

function test_setBatchResultsExport()

  iStep = 1;
  iCon = 1;

  opt.result.Steps.Contrasts.Name = 'test';
  opt.result.Steps.Contrasts.MC = 'FDR';
  opt.result.Steps.Contrasts.p = 0.05;
  opt.result.Steps.Contrasts.k = 0;

  opt.result.Steps.Output.png = true;
  opt.result.Steps.Output.csv = true;
  opt.result.Steps.Output.thresh_spm = true;
  opt.result.Steps.Output.binary = true;
  opt.result.Steps.Output.NIDM_results =  true;

  opt.space = 'individual';

  result.dir = pwd;
  result.label = '01';
  result.nbSubj = 1;
  result.contrastNb = 1;

  %%
  result.Contrasts =  opt.result.Steps(iStep).Contrasts;
  result.Output =  opt.result.Steps(iStep).Output;
  result.space = opt.space;

  matlabbatch = [];
  matlabbatch = setBatchResults(matlabbatch, result);

  expectedBatch = returnBasicExpectedResultsBatch();

  %%
  expectedBatch{end}.spm.stats.results.conspec.titlestr = returnName(result);
  expectedBatch{end}.spm.stats.results.conspec.threshdesc = 'FDR';

  expectedBatch{end}.spm.stats.results.export{1}.png = true;
  expectedBatch{end}.spm.stats.results.export{2}.csv = true;
  expectedBatch{end}.spm.stats.results.export{3}.tspm.basename = returnName(result);
  expectedBatch{end}.spm.stats.results.export{4}.binary.basename = [returnName(result) '_mask'];

  expectedBatch{end}.spm.stats.results.export{end + 1}.nidm.modality = 'FMRI';
  expectedBatch{end}.spm.stats.results.export{end}.nidm.refspace = 'ixi';
  expectedBatch{end}.spm.stats.results.export{end}.nidm.refspace = 'subject';
  expectedBatch{end}.spm.stats.results.export{end}.nidm.group.nsubj = 1;
  expectedBatch{end}.spm.stats.results.export{end}.nidm.group.label = '01';

  assertEqual(matlabbatch{end}.spm.stats.results, expectedBatch{end}.spm.stats.results);

end

function test_setBatchResultsMontage()

  iStep = 1;
  iCon = 1;

  opt.result.Steps.Contrasts.Name = '';
  opt.result.Steps.Contrasts.MC = 'FWE';
  opt.result.Steps.Contrasts.p = 0.05;
  opt.result.Steps.Contrasts.k = 0;

  opt.result.Steps.Output.montage.do =  true;

  opt.space = 'MNI';

  result.dir = pwd;
  result.label = '01';
  result.nbSubj = 1;
  result.contrastNb = 1;

  %%
  result.Contrasts =  opt.result.Steps(iStep).Contrasts;
  result.Output =  opt.result.Steps(iStep).Output;
  result.space = opt.space;

  matlabbatch = [];
  matlabbatch = setBatchResults(matlabbatch, result);

  expectedBatch = returnBasicExpectedResultsBatch();

  expectedBatch{end}.spm.stats.results.conspec.titlestr = returnName(result);
  expectedBatch{end}.spm.stats.results.conspec.threshdesc = 'FWE';

  expectedBatch{end}.spm.stats.results.export{1}.montage.background = ...
      {fullfile(spm('dir'), 'canonical', 'avg152T1.nii,1')};
  expectedBatch{end}.spm.stats.results.export{end}.montage.orientation = 'axial';
  expectedBatch{end}.spm.stats.results.export{end}.montage.slices = [];

  expectedBatch{end + 1}.spm.util.print.fname = ['Montage' returnName(result)];
  expectedBatch{end}.spm.util.print.fig.figname = 'SliceOverlay';
  expectedBatch{end}.spm.util.print.opts = 'png';

  assertEqual(matlabbatch{1}.spm.stats.results.conspec, expectedBatch{1}.spm.stats.results.conspec);
  assertEqual( ...
              matlabbatch{1}.spm.stats.results.export{1}.montage, ...
              expectedBatch{1}.spm.stats.results.export{1}.montage);

end

function expectedBatch = returnBasicExpectedResultsBatch()

  result.Contrasts.Name = '';
  result.Contrasts.p = 0.05;
  result.Contrasts.k = 0;
  result.Contrasts.MC = 'FWE';

  expectedBatch = {};
  expectedBatch{end + 1}.spm.stats.results.spmmat = {fullfile(pwd, 'SPM.mat')};

  expectedBatch{end}.spm.stats.results.conspec.titlestr = returnName(result);
  expectedBatch{end}.spm.stats.results.conspec.contrasts = 1;
  expectedBatch{end}.spm.stats.results.conspec.threshdesc = 'FWE';
  expectedBatch{end}.spm.stats.results.conspec.thresh = 0.05;
  expectedBatch{end}.spm.stats.results.conspec.extent = 0;
  expectedBatch{end}.spm.stats.results.conspec.conjunction = 1;
  expectedBatch{end}.spm.stats.results.conspec.mask.none = true();

  expectedBatch{end}.spm.stats.results.units = 1;

  expectedBatch{end}.spm.stats.results.export = [];

end
