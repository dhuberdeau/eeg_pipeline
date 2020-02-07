t = 0:.001:100;

A = 100;
B = 10;
C = .5;

f1 = 10;
f2 = 50;
f3 = 100;
p1 = pi/2;
p2 = pi+pi/5;
p3 = pi/8;

y = A*sin(f1*t*(2*pi) + p1) + B*sin(f2*t*(2*pi) + p2) + C*sin(f3*t*(2*pi) + p3);

figure; plot(t, y)

%% 
[ff, pp] = simple_psd(y, 1/mean(diff(t)));

% figure; plot(ff, -10*log10(pp));
figure; plot(ff, pp);
