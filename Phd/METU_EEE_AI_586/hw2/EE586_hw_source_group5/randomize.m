%%EE586 - Artificial Intelligence
%%METU - EE Spring 2006
%%Homework 2
%%Written by Salim SIRTKAYA, Bar�� TANRIVERD� and Bengi KO�

%%% Generate a random puzzle with the specified puzzle size %%%

% This function takes a blank puzzle and initializes it randomly

function [puzzle] = randomize(puzzle);

%% create a source list that keeps the numbers of the puzzle
random_vect = linspace(0,puzzle.size^2-1, puzzle.size^2);

for i=1:puzzle.size
    for j=1:puzzle.size
        %%assign a random number to the current location from the source list
        puzzle.nodenum(i,j) = randsrc(1,1,random_vect);
        %%remove the assigned number from the source list
        random_vect(find(random_vect==puzzle.nodenum(i,j)))= [];
    end 
end