function test_suite = test_labelActivations %#ok<*STOUT>
  % (C) Copyright 2022 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_labelActivations_basic()

  csvFile = fullfile(getDummyDataDir(), 'tsv_files', 'moae_results_table.csv');

  tsvFile = labelActivations(csvFile);

  assertEqual(exist(tsvFile, 'file'), 2);

  expectedFile = fullfile(getDummyDataDir(), 'tsv_files', 'moae_results_table.tsv');
  expectedContent = bids.util.tsvread(expectedFile);

  content = bids.util.tsvread(tsvFile);

  assertEqual(content, expectedContent);

end
