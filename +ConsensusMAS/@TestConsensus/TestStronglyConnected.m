function TestStronglyConnected(testCase, implementation)
    import ConsensusMAS.*;
    import ConsensusMAS.Utils.*;

    println("Test Fully Connected Network");
    println("Expect that average consensus is reached");

    % Simple network
    SIZE = 4;
    A = [0 1 1 1; 
         1 0 1 1;
         1 1 0 1;
         1 1 1 0];
    X0 = 0.2*(1:SIZE) - 0.1;

    % Create the network
    network = Network(implementation, A, X0);
    network.Simulate('timestep', testCase.ts, 'mintime', 5);
    network.PlotGraphStates;

    % Check the output
    final_value_expected = mean(X0);
    tol = final_value_expected * testCase.tolerance;
    assert(abs(network.final_value - final_value_expected) <= tol);
end