classdef TestConsensus < matlab.unittest.TestCase
    % https://au.mathworks.com/help/matlab/ref/matlab.unittest.testsuite.fromclass.html#ref_q237bgq7u1_sep_shared-Tag
    % https://au.mathworks.com/help/matlab/matlab_prog/use-external-parameters-in-parameterized-test.html
   
    properties
        ts = 10e-3;
        tolerance = 0.05;
    end
    properties (ClassSetupParameter)
    end
    properties(MethodSetupParameter)
    end
    properties (TestParameter)
        implementation = struct( ...
            'FixedTrigger', ConsensusMAS.Implementations.FixedTrigger, ...
            'GlobalEventTrigger', ConsensusMAS.Implementations.GlobalEventTrigger ...
        );
    end
    
    methods (TestClassSetup)
    end
    
    methods(TestMethodSetup)
    end
    
    methods (Test, TestTags = {'Undirected', 'Directed'})
        TestStronglyConnected(testCase, implementation);
        TestDisconnected(testCase, implementation);
        
    end
    
    
    methods (Test, TestTags = {'Directed'})
        TestSingleRoot(testCase, implementation);
    end
end
