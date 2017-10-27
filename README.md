# Video Split & Concat

Write a simple config text file to split one or multiple videos and concat scenes in a single one.

## Requirments

- PHP... yerk
- ffmpeg

## How to ?

See sample_run.sh

First initialise and set working folder, for example /tmp/my_videos_to_concatenate

```
./video_concat init /tmp/my_videos_to_concatenate
```

This will create a directory

- Put all your videos (or just one) in `videos_input` directory as sources

Example:
```
cp ~/my_video01.mp4 /tmp/my_videos_to_concatenate/videos_input/
cp ~/my_video02.mp4 /tmp/my_videos_to_concatenate/videos_input/
```

- Create a "config" file (check `sample_config.txt` for example), each line is a scene
```
sample.mp4 00:00:00 00:00:01
```
(video_input start_time end_time)

Example :

```
touch my_config.txt
```

Edit my_config.txt

```
my_video01.mp4 00:06:00 00:08:45
my_video01.mp4 00:12:00 00:22:45
my_video02.mp4 00:00:00 00:01:12
...
etc

```

- Execute ./video_concat run path/to/directory your_file.txt name_output_video.mp4

Example:

```
./video_concat run /tmp/my_videos_to_concatenate my_config.txt my_output_rendered_video.mp4
```

- Get your vid in output directory (/tmp/my_videos_to_concatenate/output/)



## Why this is not working ?

Well.. not yet.. still quick&dirty !

Few scenes can be skipped, idk why,
I know there are some issues, sometimes need to add one or two empty lines
at the top of the config.txt file

This script is also not well optimized, and large files could be a problem.
