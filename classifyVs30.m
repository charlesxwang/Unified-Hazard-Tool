 class = [180, 259, 360, 537, 760,  1150, 2000];
 vs30 = load('vs30.txt');
 for i = 1:length(vs30)

[c index] = min(abs(class-vs30(i)))
vs30(i) = class(index); % Finds first one only!
 end
 vs30