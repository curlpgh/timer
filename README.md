# Timer

Curling game timer to keep games on track during bonspiels. This is NOT a thinking time clock.

This application was initially conceived to be a hosted app however the Pittsburgh Curling Club's Internet access is poor. The pipe is all bunged up during bonspiels. Hence, we run this app locally on a PC in the warm room with a mirrored monitor in the ice shed. The monitor in the ice shed is a 65" TV. We have CAT-6 running out to the TV and we use an HDMI over Ethernet Extender.

# Installation

The notes in the notes/ directory describe running this application in Ubuntu Linux.

A Docker image is available at pghcc/timer. Run it in a local browser at http://localhost:4001.

# Roadmap

A possible improvement would be setting it up to run remotely using Channels to control the timer through the Admin UI. This would allow installation on a remote computer (example: Raspberry PI) attached to the ice shed monitor. This would eliminate the need for an HDMI extender and allow WIFI access to the Admin UI from any computer.

This application was written off-the-cuff so lacks tests. I never thought it would be used elsewhere. My bad.

Pull requests are welcome. https://github.com/curlpgh/timer.git

# Attribution

A big shout-out to Howard Griffin of the Potomac Curling Club for the initial idea.