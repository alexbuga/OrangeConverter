//
//  ABChartView.swift
//  GraphCharts
//
//  Created by Alex Buga on 04/05/2019.
//  Copyright © 2019 Alex Buga. All rights reserved.
//

import UIKit

@IBDesignable final class ABChartView: UIView {
    enum ChartMode {
        case Bar
        case Graph
    }
    
    fileprivate class Dataset {
        struct Bar {
            var name: String
            var percent: Float
            var value: Float
        }
        var data = [Bar]()
        var minValue: Float = 0
        var maxValue: Float = 100
        
        init() {
            //            let months = Calendar.current.shortMonthSymbols + Calendar.current.shortMonthSymbols
            //            data = [Bar]()
            //            for month in months {
            //                let value = Float.random(in: 10...100)
            //                data.append(Bar(name: month, percent: value, value: value))
            //            }
        }
        
        init(columnNames: [String], columnValues: [Float]) {
            guard columnNames.count == columnValues.count else {assertionFailure("Chart column names must match chart column values"); return}
            
            self.data.removeAll()
            minValue = columnValues.min() ?? 0
            maxValue = columnValues.max() ?? 100
            
            for i in 0..<columnValues.count {
                let percentage = (columnValues[i] - minValue) / (maxValue - minValue) * 100
                let bar = Bar(name: columnNames[i], percent: percentage, value: columnValues[i])
                self.data.append(bar)
            }
        }
    }
    
    fileprivate var dataset = Dataset()
    fileprivate var legendColor: UIView!
    fileprivate var legendName: UILabel!
    fileprivate var scrollViewOffsetTop: CGFloat {
        get {
            return layoutMargins.top + 20
        }
    }
    fileprivate var scrollView: UIScrollView!
    fileprivate var cursor: UIView!
    var stack: UIStackView!
    fileprivate var numberOfBars: Int {
        get {
            return dataset.data.count
        }
    }
    fileprivate var tooltip: UILabel!
    fileprivate var placeholderView: UIVisualEffectView!
    @objc fileprivate var graph: CAShapeLayer?
    @objc fileprivate var gradient: CAGradientLayer?
    
    @IBInspectable var title: String = NSLocalizedString("Legend", comment: "") {
        didSet {drawChart()}
    }
    @IBInspectable var barWidth: CGFloat = 10
    @IBInspectable var barsPerPage: CGFloat = 10
    var numberOfGridLines: Int = 5 {
        didSet {
            drawChart()
        }
    }
    @IBInspectable var gridLineWidth: CGFloat = 1
    @IBInspectable var showLegend: Bool = false
    @IBInspectable var padding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    @IBInspectable var isAnimated: Bool = true
    @IBInspectable var placeholder: String? {
        didSet {
            drawChart()
        }
    }
    
    var chartMode: ChartMode = .Bar {
        didSet {
            drawChart()
        }
    }
    
    private func setupView() {
        if showLegend {padding.bottom = 20}
        layoutMargins = padding
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.masksToBounds = false
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.2
//        layer.shadowRadius = 10
//        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.25
        addGestureRecognizer(longPress)
    }
    
    func setData(columnNames: [String], columnValues: [Float]) {
        dataset = Dataset(columnNames: columnNames, columnValues: columnValues)
        drawChart()
    }
    
    fileprivate var valueLabels = [UILabel]()
    fileprivate var gridLines = [UIView]()
    fileprivate var largestLabelWidth: CGFloat {
        get {
            return (valueLabels.map {$0.frame.width}.max() ?? 0) + 5
        }
    }
    
    fileprivate func drawGrid() {
        //MARK: Draw legend
        legendColor = UIView(frame: CGRect(x: layoutMargins.left, y: layoutMargins.top, width: 10, height: 10))
        legendColor.backgroundColor = tintColor
        legendColor.layer.cornerRadius = 5
        addSubview(legendColor)
        legendName = UILabel()
        legendName.text = NSLocalizedString(title, comment: "")
        legendName.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        legendName.sizeToFit()
        legendName.frame.origin.x = legendColor.frame.origin.x + legendColor.frame.width + 5
        legendName.center.y = legendColor.center.y
        addSubview(legendName)
        
        valueLabels.removeAll()
        gridLines.removeAll()
        
        let gridLineGap: CGFloat = (frame.height - scrollViewOffsetTop - layoutMargins.bottom - CGFloat(numberOfGridLines) * gridLineWidth - 5) / CGFloat(numberOfGridLines-1)
        
        //MARK: Draw labels
        
        //Calculate lower and upper bounds divided by number of gridLines
        var upperBound = dataset.maxValue
        var lowerBound = dataset.minValue
        
//        while upperBound.remainder(dividingBy: Float(numberOfGridLines-1)) != 0 {
//            upperBound += 1
//        }
//
//        while lowerBound.remainder(dividingBy: Float(numberOfGridLines-1)) != 0 {
//            lowerBound -= 1
//        }
        
        let interval = upperBound - lowerBound
        
        let delta = interval / Float(numberOfGridLines-1)
        for i in 0..<numberOfGridLines {
            let label = UILabel()
            label.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
            //MARK: Make K value
            let value = upperBound - Float(i) * delta
            func prettyValue(_ value: Float) -> String {
                if value >= 1000000 {
                    if dataset.maxValue - dataset.minValue < 1000000 {
                        return String(format: "%.2fM", value/1000000)
                    } else {
                        return String(format: "%.1fM", value/1000000)
                    }
                }
                else if value >= 1000 {
                    if dataset.maxValue - dataset.minValue >= Float(numberOfGridLines) {
                        return String(format: "%.1fK", value/1000)
                    } else {
                        return String(format: "%.0f", value)
                    }
                    
                }
                else {
                    if dataset.maxValue - dataset.minValue >= Float(numberOfGridLines) {
                        return String(format: "%.0f", value)
                    } else {
                        return String(format: "%.1f", value)
                    }
                    
                }
            }
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 4
            formatter.currencySymbol = ""
            
            label.text = formatter.string(from: NSNumber(value: value)) //prettyValue(value)
            label.textAlignment = .right
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
            label.sizeToFit()
            label.alpha = 0.4
            label.frame.origin.x = frame.width - layoutMargins.right - label.frame.width
            label.frame.origin.y = scrollViewOffsetTop + 5 + CGFloat(i) * (gridLineGap + gridLineWidth) - label.frame.height/2
            valueLabels.append(label)
            addSubview(label)
        }
        
        //MARK: Draw lines
        for i in 0..<numberOfGridLines {
            let y = scrollViewOffsetTop + 5 + CGFloat(i) * (gridLineWidth + gridLineGap)
            let gridLine = UIView(frame: CGRect(x: layoutMargins.left, y: y, width: frame.width - layoutMargins.left - layoutMargins.right - largestLabelWidth, height: gridLineWidth))
            gridLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            gridLine.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin, .flexibleTopMargin]
            gridLines.append(gridLine)
            insertSubview(gridLine, at: 0)
        }
    }
    
    func drawChart() {
        subviews.forEach{$0.removeFromSuperview()}
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blur.frame = bounds
        blur.layer.cornerRadius = 10
        blur.clipsToBounds = true
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //self.insertSubview(blur, at: 0)
        
        //MARK: Draw grid
        drawGrid()
        
        //MARK: Draw scrollview
        let height = showLegend ? frame.height - scrollViewOffsetTop : frame.height - scrollViewOffsetTop - layoutMargins.bottom
        scrollView = UIScrollView(frame: CGRect(x: layoutMargins.left, y: scrollViewOffsetTop, width: frame.width - largestLabelWidth - layoutMargins.left - layoutMargins.right, height: height))
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //scrollView.backgroundColor = UIColor.green.withAlphaComponent(0.2)
        scrollView.contentInset.left = layoutMargins.left
        addSubview(scrollView)
        
        //MARK: Draw stackview
        stack = UIStackView(frame: CGRect(origin: CGPoint(x: 0, y: 5), size: scrollView.frame.size))
        if showLegend {stack.frame.size.height -= 5 + self.layoutMargins.bottom}
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.distribution = .equalSpacing
        stack.clipsToBounds = false
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //        let bg = UIView(frame: stack.bounds)
        //        bg.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        //        stack.insertSubview(bg, at: 0)
        scrollView.addSubview(stack)
        
        //MARK: Create tooltip
        tooltip = UILabel()
        tooltip.text = NSLocalizedString("Tooltip", comment: "")
        tooltip.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        tooltip.textAlignment = .center
        tooltip.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        tooltip.textColor = .white
        tooltip.sizeToFit()
        tooltip.alpha = 0
        tooltip.layer.cornerRadius = 6
        tooltip.clipsToBounds = true
        tooltip.layer.shadowColor = UIColor.black.cgColor
        tooltip.layer.shadowOpacity = 0.4
        tooltip.layer.shadowRadius = 8
        tooltip.layer.shadowOffset.height = 3
        stack.addSubview(tooltip)
        
        //MARK: Create cursor
        cursor = UIView()
        cursor.backgroundColor = tintColor.withAlphaComponent(0.5)
        cursor.frame = CGRect(origin: .zero, size: CGSize(width: 1, height: stack.frame.height))
        cursor.isHidden = true
        cursor.autoresizingMask = [.flexibleHeight]
        stack.addSubview(cursor)
        
        let spacing: CGFloat = (stack.frame.width - barsPerPage * barWidth) / barsPerPage
        let computedWidth = CGFloat(numberOfBars) * (barWidth + spacing) - spacing
        
        //Calculate lower and upper bounds divided by number of gridLines
        var upperBound = dataset.maxValue
        var lowerBound = dataset.minValue
        
//        while upperBound.remainder(dividingBy: Float(numberOfGridLines-1)) != 0 {
//            upperBound += 1
//        }
//
//        while lowerBound.remainder(dividingBy: Float(numberOfGridLines-1)) != 0 {
//            lowerBound -= 1
//        }
        
        //MARK: Draw bars
        for item in dataset.data {
            let bar = UIView()
            bar.backgroundColor = tintColor
            stack.addArrangedSubview(bar)
            let percent = CGFloat((item.value - lowerBound) / (upperBound - lowerBound))
            let height = max(barWidth, percent * stack.frame.height) // -1 so it doesn't touch the top grid line
            bar.widthAnchor.constraint(equalToConstant: barWidth).isActive = true
            bar.heightAnchor.constraint(equalToConstant: height).isActive = true
            if item.value == 0 {
                bar.alpha = 0
            }
            
            if chartMode == .Graph && item.value > 0 {
                bar.backgroundColor = nil
                let circle = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                circle.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
                circle.center.x = bar.center.x
                circle.center.y = 0
                circle.backgroundColor = .white
                circle.layer.borderColor = tintColor.cgColor
                circle.layer.borderWidth = 2
                circle.layer.cornerRadius = 5
                bar.addSubview(circle)
            }
            
        }
        
        stack.frame.size.width = computedWidth
        stack.layoutSubviews()
        
        if showLegend {
            var legendLabels = [UILabel]()
            
            for (index, bar) in stack.arrangedSubviews.enumerated() {
                let value = dataset.data[index].name
                if index > 0 && legendLabels.last?.text == value {continue}
                let legendLabel = UILabel()
                legendLabel.font = UIFont.systemFont(ofSize: 9, weight: .medium)
                legendLabel.text = value
                legendLabel.textColor = UIColor.black.withAlphaComponent(0.5)
                legendLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                legendLabel.sizeToFit()
                legendLabel.center.x = bar.center.x
                legendLabel.frame.origin.y = stack.frame.height + 5
                stack.addSubview(legendLabel)
                legendLabels.append(legendLabel)
            }
        }
        
        
        //MARK: Draw gradients over bars
        if chartMode == .Bar {
            for bar in stack.arrangedSubviews {
                //Add gradient
                let gradient = CAGradientLayer()
                gradient.frame = bar.bounds
                gradient.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.withAlphaComponent(0.5).cgColor]
                gradient.compositingFilter = "overlayBlendMode"
                bar.layer.addSublayer(gradient)
                
                //Round top corners
                let mask = CAShapeLayer()
                let maskPath = UIBezierPath(roundedRect: bar.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: barWidth/2, height: barWidth/2))
                mask.path = maskPath.cgPath
                bar.layer.mask = mask
            }
        }
        
        scrollView.contentSize.width = stack.frame.width + spacing/2
        scrollView.contentOffset.x = scrollView.contentSize.width - scrollView.frame.width
        
        //MARK: Generate graph
        if chartMode == .Graph {
            let path = UIBezierPath()
            for (index, bar) in stack.arrangedSubviews.enumerated() {
                let x = bar.center.x
                let y = bar.center.y - bar.frame.height/2
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                }
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            graph = CAShapeLayer()
            graph!.fillColor = nil
            graph!.strokeColor = tintColor.cgColor
            graph!.lineWidth = 2
            graph!.lineJoin = .round
            graph!.lineCap = .round
            graph!.path = path.cgPath
            
            gradient = CAGradientLayer()
            gradient!.frame = stack.bounds
            gradient!.colors = [tintColor.withAlphaComponent(0.2).cgColor, tintColor.withAlphaComponent(0).cgColor]
            stack.layer.insertSublayer(graph!, at: 0)
            
            path.addLine(to: CGPoint(x: path.currentPoint.x + 100, y: path.currentPoint.y))
            path.addLine(to: CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + stack.frame.height))
            path.addLine(to: CGPoint(x: -100, y: path.currentPoint.y))
            path.close()
            
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            mask.fillColor = UIColor.white.cgColor
            
            stack.layer.insertSublayer(gradient!, at: 0)
            gradient!.mask = mask
        }
        
        //MARK: Animations
        if isAnimated {
            if let graph = graph, let gradient = gradient {
                let strokeAnimation = CABasicAnimation()
                let fromValue = (gradient.frame.width - scrollView.frame.width) / gradient.frame.width
                strokeAnimation.fromValue = fromValue
                strokeAnimation.toValue = 1
                strokeAnimation.duration = 0.7
                strokeAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeOut)
                graph.add(strokeAnimation, forKey: "strokeEnd")
                
                let gradientAnimation = CABasicAnimation()
                gradientAnimation.fromValue = 0
                gradientAnimation.toValue = 1
                gradientAnimation.duration = 0.7
                //gradientAnimation.beginTime = CACurrentMediaTime() + 0.7
                gradientAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeOut)
                gradient.add(gradientAnimation, forKey: "opacity")
            }
            
            let visibleBars = stack.arrangedSubviews
                .filter {
                    scrollView.bounds.contains($0.frame)
                }
                .sorted { (prev, next) -> Bool in
                    prev.frame.origin.x < next.frame.origin.x
            }
            
            for (index, bar) in visibleBars.enumerated() {
                bar.transform = .init(translationX: 0, y: stack.frame.height)
                let duration: Double = 1
                UIView.animate(withDuration: Double(index+1) * duration / Double(barsPerPage), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { [weak self] in
                    guard let strongSelf = self else { return }
                    bar.transform = .identity
                    strongSelf.layoutIfNeeded()
                    }, completion: nil)
            }
        }
        
        //MARK: Placeholder
        drawPlaceholderIfNeeded()
    }
    
    fileprivate func setTooltipText(_ text: String) {
        tooltip.text = text
        tooltip.sizeToFit()
        tooltip.frame.size.width += 10
        tooltip.frame.size.height += 5
        tooltip.layer.zPosition = 1000
    }
    
    @objc fileprivate func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        let taptic = UIImpactFeedbackGenerator(style: .medium)
        var location = sender.location(ofTouch: 0, in: stack)
        
        func getBarIndex() -> Int? {
            let bars = stack.arrangedSubviews
            let location = sender.location(ofTouch: 0, in: stack)
            let currentBar = bars.filter {bar in location.x > bar.frame.origin.x && location.x < bar.frame.origin.x + bar.frame.width}.first
            if currentBar == nil {return nil}
            guard let index = stack.arrangedSubviews.firstIndex(of: currentBar!), dataset.data.indices.contains(index) else {return nil}
            if currentBar?.alpha == 0 {return nil}
            else {
                return index
            }
        }
        
        func moveTooltip(to location: CGPoint, withBar bar: UIView? = nil) {
            tooltip.frame.origin.x = max(layoutMargins.left, min(frame.width - layoutMargins.right - tooltip.frame.width, location.x - tooltip.frame.width/2))
            
            if let bar = bar {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tooltip.frame.origin.y = bar.frame.origin.y
                    }, completion: nil)
            } else {
                self.tooltip.frame.origin.y = self.scrollViewOffsetTop + 2
            }
        }
        
        func moveTooltipAndCursor(to x: CGFloat, animated: Bool = false) {
            UIView.animate(withDuration: animated ? 0.2 : 0, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                guard let strongSelf = self else { return }
                let minX = strongSelf.tooltip.frame.width/2 + strongSelf.scrollView.contentOffset.x
                let maxX = strongSelf.scrollView.frame.width - strongSelf.tooltip.frame.width/2 + strongSelf.scrollView.contentOffset.x
                strongSelf.tooltip.center.x = max(minX, min(maxX, x))
                strongSelf.tooltip.frame.origin.y = 2
                strongSelf.cursor.center.x = max(0, min(strongSelf.stack.frame.width + strongSelf.layoutMargins.right - strongSelf.cursor.frame.width/2, x))
                }, completion: nil)
        }
        
        switch sender.state {
        case .began:
            scrollView.isScrollEnabled = false
            cursor.isHidden = false
            
            if let index = getBarIndex() {
                let text = String(format: "%@: %.4f", dataset.data[index].name, dataset.data[index].value)
                setTooltipText(text)
                let bar = stack.arrangedSubviews[index]
                moveTooltipAndCursor(to: bar.center.x)
            } else {
                setTooltipText(NSLocalizedString("Move your finger", comment: ""))
                moveTooltipAndCursor(to: location.x)
            }
            
            tooltip.transform = .init(translationX: 0, y: 20)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tooltip.alpha = 1
                strongSelf.tooltip.transform = .identity
                }, completion: nil)
            
            taptic.prepare()
            taptic.impactOccurred()
            
        case .ended:
            scrollView.isScrollEnabled = true
            cursor.isHidden = true
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tooltip.alpha = 0
                }, completion: nil)
            taptic.prepare()
            taptic.impactOccurred()
            
        case .changed:
            
            if let index = getBarIndex() {
                let text = String(format: "%@: %.4f", dataset.data[index].name, dataset.data[index].value)
                setTooltipText(text)
                if shouldTap {
                    taptic.prepare()
                    taptic.impactOccurred()
                    shouldTap = false
                    
                    if let index = getBarIndex() {
                        let bar = stack.arrangedSubviews[index]
                        moveTooltipAndCursor(to: bar.center.x, animated: true)
                    }
                    
                }
            } else {
                shouldTap = true
            }
            break
        default:
            break
        }
    }
    
    func drawPlaceholderIfNeeded() {
        if let placeholder = placeholder {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blur.clipsToBounds = true
            blur.layer.cornerRadius = layer.cornerRadius
            blur.tag = 999
            var frame = bounds
            frame.origin.y += scrollViewOffsetTop
            frame.size.height -= scrollViewOffsetTop
            blur.frame = frame
            blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            label.alpha = 0.4
            label.text = placeholder
            label.textColor = .black
            label.sizeToFit()
            label.center = blur.contentView.center
            blur.contentView.addSubview(label)
            addSubview(blur)
        } else {
            guard let blur = viewWithTag(999) as? UIVisualEffectView else {return}
            blur.removeFromSuperview()
        }
    }
    
    var shouldTap = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        drawChart()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        drawChart()
    }
    
    internal override var bounds: CGRect {
        didSet {
            drawChart()
        }
    }
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        drawChart()
    }
    
    internal override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
        drawChart()
    }
}
