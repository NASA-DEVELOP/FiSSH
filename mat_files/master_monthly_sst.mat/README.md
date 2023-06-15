# README

Because GitHub has a limit of 25MB upload for any given single file, one of the data files, `master_monthly_sst.mat`, was split into 24MB chunks using to the Unix `split` command (use "`man split`" for documentation).

`303453896 Aug 9 2018    master_monthly_sst.mat`

To join the file back to it's original 303MB size, use the following command:

`cat xaa xab xac xad xae xaf xag xah xai xaj xak xal xam > master_monthly_sst.mat`
