function TestDisconnected(testCase, implementation)
    import ConsensusMAS.*;
    import ConsensusMAS.Utils.*;

    println("\nTest Disconnected Network");
    println("Expect that consensus is not reached");

    % Simple network
    SIZE = 4;
    A = [0 0 0 0; 
         0 0 0 0;
         0 0 0 0;
         0 0 0 0];
    X0 = 0.2*(1:SIZE) - 0.1;

    % Create the network
    network = Network(implementation, A, X0);
    network.Simulate('timestep', testCase.ts, 'maxsteps', 1e3);
    network.PlotGraphStates;

    % Check the output
    assert(~network.consensus);
end