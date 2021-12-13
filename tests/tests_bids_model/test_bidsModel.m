% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_bidsModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnModelStep()

  content = createEmptyStatsModel();
  content.Steps{4} = createEmptyNode('dataset');

  [~, iStep] = returnModelStep(content, 'run');
  assertEqual(iStep, 1);

  [~, iStep] = returnModelStep(content, 'dataset');
  assertEqual(iStep, [3; 4]);

  assertExceptionThrown( ...
                        @()returnModelStep(content, 'foo'), ...
                        'returnModelStep:missingModelStep');

end

function test_getHighPassFilter()

  opt = setOptions('vislocalizer', '01');

  HPF = getHighPassFilter(opt.model.file);

  assertEqual(HPF, 128);

end

function test_getBidsDesignMatrix()

  opt = setOptions('vislocalizer', '01');

  designMatrix = getBidsDesignMatrix(opt.model.file);

  expected = {'trial_type.VisMot'
              'trial_type.VisStat'
              'trial_type.missing_condition'
              'trans_x'
              'trans_y'
              'trans_z'
              'rot_x'
              'rot_y'
              'rot_z'};

  assertEqual(designMatrix, expected);

end

function test_getContrastsList()

  opt = setOptions('vislocalizer', '01');

  contrastsList = getContrastsList(opt.model.file);

  assertEqual(fieldnames(contrastsList), {'Name'
                                          'ConditionList'
                                          'weights'
                                          'type'});

  assertEqual(numel(contrastsList), 2);

end

function test_getDummyContrastsList()

  opt = setOptions('vislocalizer', '01');

  DummyContrastsList = getDummyContrastsList(opt.model.file);

  expected = {'trial_type.listening'
              'trial_type.VisMot'};

  assertEqual(DummyContrastsList, expected);

end
