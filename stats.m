function return_val = stats(activities, hs, participant)

% Calculate samples of data
[count, count_activity] = groupcounts(activities);

% Calcuate steps of data
step_activities = activities(hs);
[step_count, step_count_activity] = groupcounts(step_activities);

% Calculate number of transitions
transitions_count = sum(activities(1:end-1) ~= activities(2:end));


return_val.count = count;
return_val.count_activity = count_activity;
return_val.step_count = step_count;
return_val.step_count_activity = step_count_activity;
return_val.transitions_count = transitions_count;
return_val.participant = participant;

end



