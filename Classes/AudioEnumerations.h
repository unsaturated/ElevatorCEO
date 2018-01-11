/**
 * Elevator CEO is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *  
 * Elevator CEO is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *  
 * You should have received a copy of the GNU General Public License
 * along with Elevator CEO. If not, see 
 * https://github.com/unsaturated/ElevatorCEO/blob/master/LICENSE.
 */

/**
 * Defines the sound effects that can be played.
 */
typedef enum 
{
	kInvalidElevatorButton, // buzzer [done]
    kPensionBonus,          // coins
    kNewLevelTransition,    // dingdong
	kTapElevatorButton,     // elevator-button
	kElevatorCrash,         // elevator-crash
    kElevatorMoving,        // elevator-hum
    kElevatorStopping,      // elevator-shutdown
    kElevatorStarting,      // elevator-startup
    kTreasureChestOpening,  // glockenspiel
    kIntroLoop,             // livemusic
    kClickMenuButton,       // menubutton 
    kNoRadarBonus,          // powerdown
    kLifeBonus,             // recharge-big
    kSynergyBonus,          // recharge-small
    kBooster,               // rocket
    kRecoverRadar,          // staticdischarge
    kStinger,               // stinger
    kPassengerBonus,        // successful
    kSwapControlSides,      // swap
    kLowSynergyWarning      // warning
} SoundEffect;

