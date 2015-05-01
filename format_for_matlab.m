function [ eqn ] = format_for_matlab( charsGuessed )
% Format the decoded equation for matlab

% Remove 'y=', turn ^, * into .^, .*
eqn = charsGuessed;
eqn = eqn(3:end); %get rid of y=
eqn = strrep(eqn, '^', '.^');
eqn = strrep(eqn, '*', '.*');

% Insert .* between numbers and x
eqn = regexprep(eqn, '([0-9])x', '$1.*x');

end

