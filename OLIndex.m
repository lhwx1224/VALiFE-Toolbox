function OLI = OLIndex(Omega, rol)
[m, n] = size(Omega);
omegam = Omega(m,:);
OLI = Omega;
for j = 1 : n-rol
    nf = 0;
    k = 1;
    while nf == 0 && k <= rol
        if omegam(j + k) == 1 && k <= rol
            nf = 1;
        end
        k = k + 1;
    end
    k = k - 1;
    if sum(Omega(:, j)) < sum(Omega(:, j + k))
        OLI(:,j) = zeros(m, 1);
    end
end

for j = n : -1 : n-2*rol
    nf = 0;
    k = 1;
    while nf == 0 && k <= rol
        if omegam(j - k) == 1 && k <= rol
            nf = 1;
        end
        k = k + 1;
    end
    k = k - 1;
    if sum(Omega(:, j)) < sum(Omega(:, j - k))
        OLI(:,j) = zeros(m, 1);
    end
end