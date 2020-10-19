figure(), hold on;

for i = 1:10
    plot(sin(2 * pi * i/10), cos(2 * pi * i/10), 'x');
end