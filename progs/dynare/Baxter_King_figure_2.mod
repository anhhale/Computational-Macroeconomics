% =========================================================================
% replicates figure 2 of Baxter and King (1993, American Economic Review)
% note that this is the Benchmark model with Basic Government Purchases,
% but no productive government investment
%-------------------------------------------------------------------------%
% To Do:
% - add term structure variable
% =========================================================================
% Willi Mutschler (willi@mutschler.eu)
% Version: April 26, 2023
% =========================================================================

%-------------------------------------------------------------------------%
% declare variables and parameters
%-------------------------------------------------------------------------%
var
  y    // output
  c    // consumption
  l    // leisure
  n    // labor
  iv   // private investment
  k    // private capital stock
  lam  // Lagrange multiplier budget constraint
  tr   // fiscal transfers
  tau  // net tax rate
  gb   // basic government spending
  w    // real wage
  q    // after tax rental rate of capital
  r    // real interest rate
  uc   // marginal utility with respect to consumption
  ul   // marginal utility with respect to leisure
  fn   // marginal product of labor
  fk   // marginal product of capital  
  check_walras // redundant variable that checks whether resource constraint is full-filled according to Walras law
;

varexo  
  e_gb   // basic government spending shock
;

parameters
  A         // common technology level
  GAMMAX    // growth rate of labor-augmenting technology according to footnote 3
  BETA      // discount factor
  THETA_L   // weight of leisure in utility function
  DELTA_K   // capital depreciation rate
  THETA_K   // private capital productivity in production function
  THETA_N   // labor productivity in production function
  GB_BAR    // target value of basic government spending
  TAU_BAR   // target value of tax rate  
;

%-------------------------------------------------------------------------%
% model equations
%-------------------------------------------------------------------------%
model;

[name='marginal utility wrt consumption given momentary utility in eq. (2)']
uc = c^(-1);

[name='marginal utility wrt leisure given momentary utility in eq. (2)']
ul = THETA_L*l^(-1);

[name='production function, eq. (3)']
y = A * k(-1)^THETA_K * n^THETA_N;

[name='marginal product of capital given Cobb-Douglas production function in eq. (3)']
fk = THETA_K*A*k(-1)^(THETA_K-1)*n^THETA_N;

[name='marginal product of labor given Cobb-Douglas production function in eq. (3)']
fn = THETA_N*A*k(-1)^THETA_K*n^(THETA_N-1);

[name='law of motion private capital stock, eq. (4) combined with footnote (3)']
GAMMAX*k = (1-DELTA_K)*k(-1) + iv;

[name='time endowment, eq. (6)']
l + n = 1;

[name='resource constraint, eq. (7) (redundant due to Walras law)']
c + iv = (1-tau)*y + tr + check_walras;

[name='market clearing, eq. (8)']
c + iv + gb = y;

[name='government budget constraint, eq. (9)']
tau*y = gb + tr;

[name='shadow price of consumption utility, eq. (10)']
uc = lam;

[name='labor-leisure decision combined with labor demand, eq. (11)']
ul = lam*(1-tau)*fn;

[name='savings decision, eq. (12) combined with footnote (3)']
BETA * lam(+1) * (q(+1) + 1 - DELTA_K) = GAMMAX*lam;

[name='after tax rental rate of capital, below eq. (13)']
q = (1-tau)*fk;

[name='fiscal rule: government spending']
gb = GB_BAR + e_gb;

[name='fiscal rule: tax rate']
tau = TAU_BAR;

[name='one period real interest rate, page 322 center, better: see King, Plosser, and Rebelo (1988) page 204 above section 3']
1+r = GAMMAX*lam/(lam(+1)*BETA);

[name='real wage, see King, Plosser, and Rebelo (1988) page 204 above section 3']
w = fn;

end;

%-------------------------------------------------------------------------%
% Calibation yearly according to Table 1
% I.Benchmark Model with Basic Government Purchases and no Government Investment
%-------------------------------------------------------------------------%
A = 1; % normalize
% growth rate, see footnote 3
GAMMAX = 1+0.016; % value follows King, Plosser, Rebello (1988) or King and Rebelo (1999)
% production function
THETA_K = 0.42;
THETA_N = 1-THETA_K; % constant returns to scale
DELTA_K = 0.10;
%preferences
N = 0.2;
L = 1-N;
R = 0.065;
BETA = GAMMAX/(1+R); % real interest rate in steady-state
% government
sG  = 0.20;     % government spending over output G/Y
TAU_BAR = 0.20; % same tax rate as government spending ratio implies zero transfers
TR  = 0;
TAU = TAU_BAR;

RK  = (GAMMAX/BETA-1+DELTA_K)/(1-TAU_BAR); % savings decision in steady-state
K_N = (THETA_K/RK)^(1/(1-THETA_K));        % capital demand with THETA_N=1-THETA_K in steady-state
K   = K_N*N;                               % definition in steady-state
Y   = N^(1-THETA_K)*K^THETA_K;             % production function in steady-state
W   = (1-THETA_K)*Y/N;                     % labor demand in steady-state
IV  = (GAMMAX-1+DELTA_K)*K;                % private capital accumulation in steady-state
GB_BAR = sG*Y; GB = GB_BAR;                % definition spending ratio in steady-state
C   = Y-IV-GB;                             % ressource constraint in steady-state
LAM = 1/C;                                 % marginal utility in steady-state
THETA_L = (1-TAU)*W*(1-N)/C;               % labor supply in steady-state

% remaining variables in steady-state
UC  = C^(-1);
UL  = THETA_L*L^(-1);
FK  = THETA_K*A*K^(THETA_K-1)*N^THETA_N;
FN  = THETA_N*A*K^THETA_K*N^(THETA_N-1);
Q   = (1-TAU)*FK;

%-------------------------------------------------------------------------%
% simulation: transition to new steady-state
%-------------------------------------------------------------------------%
% STEP 1: SET INITIAL CONDITION
initval;
  e_gb  = 0;
  y     = Y;
  c     = C;
  l     = L;
  n     = N;  
  iv    = IV;
  k     = K;  
  lam   = LAM;
  tr    = TR;
  tau   = TAU;  
  gb    = GB;
  r     = R;
  check_walras = 0;
end;
steady; % compute initial steady-state
        % steady after intival uses the computed steady-state to initialize oo_.endo_simul
        % the computed steady-state is available in oo_.steady_state, the rows correspond to M_.endo_names

% STEP 2: SET TERMINAL CONDITION
commodity_unit = 0.01*oo_.steady_state(M_.endo_names=="y"); % commodity unit (p.321) defined as 1% of initial output

endval;
  e_gb = commodity_unit; % basic government spending is increased permanently by a commodity unit using the exogenous variables
end;                     % other variables remain at initial steady-state

steady; % recompute steady-state numerically starting from old steady-state and changing e_gb
        % steady after endval will set the terminal condition oo_.endo_simul(:,end) to the new steady-state

% STEP 3: COMPUTE TRANSITION PATH
perfect_foresight_setup(periods=200);
perfect_foresight_solver; % simulate transition path based on nonlinear model equations
%perfect_foresight_solver(linear_approximation); % simulate transition path based on linearized model equations

%-------------------------------------------------------------------------%
% Figure 2: Macroeconomic Effects of A Permanent Increase in Basic Government Purchases
%-------------------------------------------------------------------------%
% oo_.endo_simul contains the simulated variables,
% note that the first entry is the initial condition (initval steady-state)
% and the last is the terminal condition (endval steady-state)

% indices to access the variables in oo_.endo_simul
idx_y  = varlist_indices('y', M_.endo_names);
idx_c  = varlist_indices('c', M_.endo_names);
idx_iv = varlist_indices('iv',M_.endo_names);
idx_n  = varlist_indices('n', M_.endo_names);
idx_w  = varlist_indices('w', M_.endo_names);
idx_r  = varlist_indices('r', M_.endo_names);

% do transformations on plotted variables
horizon = 1:22;
plot_y  = (oo_.endo_simul(idx_y,horizon+1)-oo_.endo_simul(idx_y,1))./commodity_unit;   % deviation from initial steady-state, normalized in commidity units
plot_c  = (oo_.endo_simul(idx_c,horizon+1)-oo_.endo_simul(idx_c,1))./commodity_unit;   % deviation from initial steady-state, normalized in commidity units
plot_iv = (oo_.endo_simul(idx_iv,horizon+1)-oo_.endo_simul(idx_iv,1))./commodity_unit; % deviation from initial steady-state, normalized in commidity units
plot_n  = 100*(oo_.endo_simul(idx_n,horizon+1)./oo_.endo_simul(idx_n,1)-1);            % percentage deviation from initial steady-state, in percent
plot_w  = 100*(oo_.endo_simul(idx_w,horizon+1)./oo_.endo_simul(idx_w,1)-1);            % percentage deviation from initial steady-state, in percent
plot_r  = 100*100*(oo_.endo_simul(idx_r,horizon+1) - oo_.endo_simul(idx_r,1));         % percentage point deviation from initial steady-state, in basis points

% Figure 2: Commodity Market
figure(name="Commodity Market");
hold on;
plot(horizon,plot_y,  "o",'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8,'LineStyle','none');
plot(horizon,plot_c,  "^",'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8,'LineStyle','none');
plot(horizon,plot_iv, "x",'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8,'LineStyle','none');
yline(0,'LineWidth',2);
set(gca,'FontSize',12);
legend(["Output", "Consumption", "Investment"],'Location','SouthEast','Box', 'off');
xlabel('Years');
ylabel('Commodity Units');
xticks(horizon)
ylim([-1.2,1.2])
yticks(-1.2:0.3:1.2)
hold off

% Figure 2: Labor Market
figure(name="Labor Market");
hold on;
plot(horizon,plot_n,"o",'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8,'LineStyle','none');
plot(horizon,plot_w,"^",'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8,'LineStyle','none');
yline(0,'LineWidth',2);
set(gca,'FontSize',12);
legend(["Labor Input", "Real Wage"],'Location','SouthEast','Box', 'off');
xlabel('Years');
ylabel('Percent');
xticks(horizon)
ylim([-1.6,1.6])
yticks(-1.6:0.4:1.6)
hold off

% Figure 2: Financial Market (term structure not yet)
figure(name="Financial Market");
hold on;
plot(horizon,plot_r,"o",'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8,'LineStyle','none');
yline(0,'LineWidth',2);
set(gca,'FontSize',12);
legend(["Real Interest Rate"],'Location','NorthEast','Box', 'off');
xlabel('Years');
ylabel('Basis Points');
xticks(horizon)
ylim([0,12])
yticks(0:1:12)
hold off