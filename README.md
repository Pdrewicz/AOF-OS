Install:<br />
&emsp;wget run https://aof-os.pdrewicz.site/os/client/start.lua<br /><br />

Creating apps:<br />
  &emsp;apps are saved in /programs/[name]/<br />
  &emsp;use 'require("/basalt")' for shared ui library<br />
  &emsp;for stuff only meant to happen when app is used through AOF-OS check for arg[1] == "aof-os"<br />

  &emsp;editable properties:
    &emsp;{<br />
        &emsp;&emsp;"name": "musicPlayer",<br />
        &emsp;&emsp;"displayName": "Music player",<br />
        &emsp;&emsp;"url": "http://aof-os.pdrewicz.site/musicplayer/client/startUI.lua",  //Installer url<br />
        &emsp;&emsp;"bg": "b",  //Background<br />
        &emsp;&emsp;"fg": "f",  //Foreground<br />
        &emsp;&emsp;"icon": 14,<br />
        &emsp;&emsp;"iconColor": "1",<br />
        &emsp;&emsp;"borderColor": "f"<br />
    &emsp;}

  &emsp;icons:
  
  &emsp;![image](https://github.com/Pdrewicz/AOF-OS/assets/106173218/cced3426-6041-4a43-9787-96839327b354)

  &emsp;colors:

  &emsp;![image](https://github.com/Pdrewicz/AOF-OS/assets/106173218/b249ab63-ea7a-4410-a652-c54760ba806e)




