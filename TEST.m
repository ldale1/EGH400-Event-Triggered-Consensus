figure(), hold on;

for i = 1:10
    
    plot(sin(i*2*pi/10), cos(i*2*pi/10), 'x')
end