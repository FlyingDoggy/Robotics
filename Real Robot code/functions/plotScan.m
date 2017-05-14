function plotScan( scans )

num = size(scans, 1);
theta = -2*pi / num;
angle = 0;
x(num) = 0;
y(num) = 0;

for i = 1:num
    x(i) = sin(angle) * scans(i);
    y(i) = cos(angle) * scans(i);
    angle = angle + theta;
end

x = [x,x(1)];
y = [y,y(1)];

plot(x, y);
hold on;
axis equal;
plot(0, 0, 'o');
hold off;

end

