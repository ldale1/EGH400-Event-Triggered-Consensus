function TestSingleRoot(testCase, implementation)
    import ConsensusMAS.*;
    import ConsensusMAS.Utils.*;

    println("\nTest One Root Node");
    println("Expect that root node consensus is reached");
    
    SIZE = 4;
    A = [0 0 0 1;
         0 0 0 1;
         0 0 0 1;
         0 0 0 0];
    X0 = 0.2*(1:SIZE) - 0.1;

    % Create the finite time network
    network = Network(implementation, A, X0);
    network.Simulate('timestep', testCase.ts, 'mintime', 20, 'maxsteps', 1e4);
    network.PlotGraphStates;
end