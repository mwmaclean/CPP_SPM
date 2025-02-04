function test_suite = test_setBatchFactorialDesign %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchFactorialDesignBasic()

  funcFWHM = 6;
  conFWHM = 6;

  opt.subjects = {'01' '02'};
  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'vismotion';
  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'dummyData', 'models', 'model-visMotionLoc_smdl.json');

  opt = checkOptions(opt);

  matlabbatch = [];
  matlabbatch = setBatchFactorialDesign(matlabbatch, opt, funcFWHM, conFWHM);

  % TODO
  % add assert

end
