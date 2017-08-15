//
//  EstimatePedestrianStatus.swift
//  Pedestrian Status
//
//  Created by Can on 25/07/2017.
//  Copyright © 2017 Can Sürmeli. All rights reserved.
//

import Foundation
import CoreMotion

extension PedestrianStatusVC {
	func estimatePedestrianStatus(_ acceleration: CMAcceleration) {
		// Filter raw acceleration to avoid the device's jiggling
		filteredXAcceleration = acceleration.x.round().lowPassFilter(lowPassFilterPercentage,
                                                                     previousValue: filteredXAcceleration)

		filteredYAcceleration = acceleration.y.round().lowPassFilter(lowPassFilterPercentage,
                                                                     previousValue: filteredYAcceleration)

		filteredZAcceleration = acceleration.z.round().lowPassFilter(lowPassFilterPercentage,
                                                                     previousValue: filteredZAcceleration)

		// MARK: Euclidean Norm Calculation
		// Take the squares to the low-pass filtered x-y-z axis values
		let xAccelerationSquared = filteredXAcceleration.squared().round()
		let yAccelerationSquared = filteredYAcceleration.squared().round()
		let zAccelerationSquared = filteredZAcceleration.squared().round()

		// Calculate the Euclidean Norm of the x-y-z axis values
		let accelerometerDataInEuclideanNorm = sqrt(xAccelerationSquared + yAccelerationSquared + zAccelerationSquared).round()

		// MARK: Euclidean Norm Variance Calculation
		// record 10 consecutive euclidean norm values, that
		// is values gathered and calculated in a second since
		// the accelerometer frequency is set to 0.1 s
		while accelerometerDataInASecond.count < 10 {
			accelerometerDataInASecond.append(accelerometerDataInEuclideanNorm)

			break	// required since we want to obtain data every accelerometer cycle
						// otherwise goes to infinity
		}

		// when accelerometer values are recorded
		if accelerometerDataInASecond.count == 10 {
			// Calculating the variance of the Euclidian Norm of the accelerometer data
			let accelerationMean = (accelerometerDataInASecond.reduce(0, +) / Double(accelerometerDataInASecond.count)).round()
			var totalAcceleration = 0.0

			for data in accelerometerDataInASecond {
				totalAcceleration += ((data-accelerationMean) * (data-accelerationMean)).round()
			}

			totalAcceleration = totalAcceleration.round()

			let result = (totalAcceleration / 10).round()

			if (result < 0.013) {
				pedestrianStatus = "Static"
			} else if ((0.013 <= result) && (result <= 0.05)) {
				pedestrianStatus = "Slow Walking"
				stepCount += 1
			} else if 0.05 < result {
				pedestrianStatus = "Fast Walking"
				stepCount += 2
			}

			// reset for the next round
			accelerometerDataInASecond.removeAll(keepingCapacity: false)
		}
	}
}
