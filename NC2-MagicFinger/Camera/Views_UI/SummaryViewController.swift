////
////  SummaryViewController.swift
////  NC2-MagicFinger
////
////  Created by Chang Jonghyeon on 6/18/24.
////
//
//import UIKit
//
//class SummaryViewController: UIViewController {
//    @IBOutlet weak var tableView: UITableView!
//    private var sortedActions = [String]()
//    var actionFrameCounts: [String: Int]? {
//        didSet {
//            guard let frameCounts = actionFrameCounts else { return }
//            sortedActions.removeAll()
//            let sortedElements = frameCounts.sorted { $0.value > $1.value }
//            sortedElements.forEach { entry in sortedActions.append(entry.key) }
//        }
//    }
//    var dismissalClosure: (() -> Void)?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view?.overrideUserInterfaceStyle = .dark
//        tableView.dataSource = self
//        tableView.reloadData()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        dismissalClosure?()
//        super.viewDidDisappear(animated)
//    }
//}
//
//extension SummaryViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sortedActions.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let customCellName = "SummaryCellPrototype"
//        let cell = tableView.dequeueReusableCell(withIdentifier: customCellName, for: indexPath)
//        guard let summaryCell = cell as? SummaryTableViewCell else {
//            fatalError("Not an instance of `SummaryTableViewCell`.")
//        }
//        if let frameCounts = actionFrameCounts {
//            let frameRate = ExerciseClassifier.frameRate
//            let action = sortedActions[indexPath.row]
//            let totalFrames = frameCounts[action] ?? 0
//            let totalDuration = Double(totalFrames) / frameRate
//            summaryCell.totalDuration = totalDuration
//            summaryCell.actionLabel.text = action
//        }
//        return summaryCell
//    }
//}
//
//class SummaryTableViewCell: UITableViewCell {
//    @IBOutlet weak var actionLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
//    var totalDuration: Double = 0 {
//        didSet { timeLabel.text = String(format: "%0.1fs", totalDuration) }
//    }
//}
