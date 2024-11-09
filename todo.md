**Meantime
- [ ] Ascent script: suborbital trajectory equation & insertion loop
    - [x] Launch window time precision (target orbit)
    - [x] implement launch azimuth calculation (from python script)
    - [x] roll program & pitch program 
    - [ ] attitude control using pid loops (next gen guidance) for precision and to keep aoa at 0.
    - [ ] account for insufficient burn time to circularize (staging calcs)
- [x] fix deltav & debug list was edited (ship:parts) (shit !)
- [ ] rcs deltav and more advanced parts stage grouping stuff

- [x] intercept circular orbit satellites
- [x] launch & intercept eleptic satellites,(from initial circular obit) using mean anomaly 
	- [ ] add some lag maneuver to intecept with low relative velocity and rcs only (realistic safe meneuvers).
- [ ] rcs thrusters vector guidance

**Advanced: 
- [ ] launch to specific orbit given elements
- [ ] flight telemtry and data science logging

- [ ] approximate suborbital reentry trajectory mid flight (if reusable)
- [ ] hoverslam with 3 engines and startup delay time
- [ ] simulate gradual thrust (random intervals)

- [ ] hover navigate and land (for lunar missions)

- [ ] Space shuttle launch and landing [landing,trajectory,adv ascent algo (custom pid)
	- [ ] response time pids
	- [ ] stall speed test
	- [ ] Aerodynamic landing 
- [ ] aerodynamic pod reentry, control descent with pid (roll control relative to com offset)

