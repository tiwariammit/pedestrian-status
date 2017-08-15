//
//  ViewController.swift
//  Pedestrian Status
//
//  Created by Can on 17/09/15.
//  Copyright © 2015 Can Sürmeli. All rights reserved.
//

import UIKit
import CoreMotion

class PedestrianStatusVC: UIViewController {
	let motionManager = CMMotionManager()
	var filteredXAcceleration = 0.0
	var filteredYAcceleration = 0.0
	var filteredZAcceleration = 0.0
	var accelerometerDataInASecond = [Double]()
  var lowPassFilterPercentage = 15.0

	@IBOutlet weak var pedestrianStatusLabel: UILabel!
	var pedestrianStatus: String! {
		didSet {
			pedestrianStatusLabel.text = pedestrianStatus
		}
	}

	@IBOutlet weak var stepCountLabel: UILabel!
	var stepCount = 0 {
        didSet {
			stepCountLabel.text = String(stepCount)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		motionManager.accelerometerUpdateInterval = 0.1

		motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
			guard let accelerometerData = data
				else {
					if let error = error { print(error) }

					return
				}

			self?.estimatePedestrianStatus(accelerometerData.acceleration)
		}
	}
}
