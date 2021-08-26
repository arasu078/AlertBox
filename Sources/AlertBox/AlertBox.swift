import UIKit

public protocol AlertBoxDelegate: NSObjectProtocol {
    func alertBoxDidSelect(alertBox: AlertBox, buttonIndex: Int, date: Date?)
}

extension AlertBoxDelegate {
    func alertBoxDidSelect(alertBox: AlertBox, buttonIndex: Int, date: Date?){}
}


//DatePicker Mode
public enum DatePickerType {
    case date, time, countdown
    public func dateType() -> UIDatePicker.Mode {
        switch self {
        case .date: return .date
        case .time: return .dateAndTime
        case .countdown: return .countDownTimer
        }
    }
}

private var ALERT_BOX_MARGIN: CGFloat = 15.0
private let ALERT_BOX_Y_OFFSET: CGFloat = 116.0
private var ALERT_BOX_WIDTH: CGFloat = UIScreen.main.bounds.width - 30.0
private let ALERT_BOX_HEIGHT: CGFloat = 363.0

private let TITLE_LABEL_HEIGHT: CGFloat = 49.0
private let SEPRATOR_HEIGHT: CGFloat = 1.0
private let BUTTON_HEIGHT: CGFloat = 50.0

private let LABEL_COLOR = UIColor(red: 252.0/255.0, green: 61.0/255.0, blue: 57.0/255.0, alpha: 1.00)
private let FONT_SIZE = UIFont(name: "Helvetica", size: 18)
private let TIME_FORMATE = "hh:mm a"
private let DATE_FORMATE = "dd-MMM-YY"


open class AlertBox: UIView, UIGestureRecognizerDelegate {
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Delegate
    var delegate: AlertBoxDelegate?
    
    //Properties
    var backgroundView: UIView!
    var alertBoxView: UIView!
    
    var titleLabel: UILabel!
    var topSeprator: UILabel!
    var messageTextView: UITextView!
    var datePickerView: UIDatePicker!
    var bottomSeprator: UILabel!
    
    var closeButton:UIButton!
    var doneButton:UIButton!
    
    //Custom Properties
    open var showBlur = true //Default Yes
    open var datePickerType: DatePickerType!
    open var tapToDismiss = true //Default Yes
    open var datePickerStartDate = Date() //Optional
    
    var pickerDate: Date!
    
    private var kCornerRadius: CGFloat = 7.0
    
    //MARK:- INITIALIZERS
    public init(withPromtTitle title: String,message: String, delegate: AlertBoxDelegate?, okButtonTitle:String, cancelButtonTitle:String?) {
        super.init(frame: CGRect.zero)
        
        self.delegate = delegate
        
        backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        
        alertBoxView = creatAlertBoxView()
        backgroundView.addSubview(alertBoxView)
        
        titleLabel = addTitleLabel()
        titleLabel.text = title
        alertBoxView.addSubview(titleLabel)
        
        topSeprator = addSeprator(frame: CGRect.zero)
        alertBoxView.addSubview(topSeprator)
        
        messageTextView = createMessageTextView()
        messageTextView.text = message
        alertBoxView.addSubview(messageTextView)
        
        bottomSeprator = addSeprator(frame: CGRect.zero)
        alertBoxView.addSubview(bottomSeprator)
        
        if (cancelButtonTitle != nil)
        {
            closeButton = createButtonWithTag(cancelButtonTitle!, 0)
            alertBoxView.addSubview(closeButton)
        }
        if !okButtonTitle.isEmpty
        {
            doneButton = createButtonWithTag(okButtonTitle, 1)
            alertBoxView.addSubview(doneButton)
        }
        
        setNeedsLayout()
    }
    
     public convenience init(withPickerMessage message: String, delegate: AlertBoxDelegate?, okButtonTitle:String, cancelButtonTitle:String?) {
        self.init(withPromtTitle: "", message: message, delegate: delegate, okButtonTitle: okButtonTitle, cancelButtonTitle: cancelButtonTitle)
        
        datePickerView = createDatePicker()
        titleLabel.text = picketTitleFormate(date: self.datePickerView.date)
        alertBoxView.addSubview(datePickerView)
        
        setNeedsLayout()
    }
    
    // MARK:- UI CREATION
    private func creatAlertBoxView() -> UIView {
        let alertView = UIView(frame: CGRect.zero)
        
        alertView.autoresizingMask = [.flexibleWidth]
        alertView.backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 244/255, alpha: 82)
        
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = alertView.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor,
                           UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor,
                           UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor]
        
        gradient.cornerRadius = kCornerRadius
        alertView.layer.insertSublayer(gradient, at: 0)
        
        alertView.layer.cornerRadius = kCornerRadius
        alertView.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        alertView.layer.borderWidth = 1
        alertView.layer.shadowRadius = kCornerRadius + 5
        alertView.layer.shadowOpacity = 0.1
        alertView.layer.shadowOffset = CGSize(width: 0 - (kCornerRadius + 5) / 2, height: 0 - (kCornerRadius + 5) / 2)
        alertView.layer.shadowColor = UIColor.black.cgColor
        alertView.layer.shadowPath = UIBezierPath(roundedRect: alertView.bounds, cornerRadius: alertView.layer.cornerRadius).cgPath

        return alertView
    }
    
    private func addTitleLabel() -> UILabel {
        let Label = UILabel(frame: CGRect.zero)
        Label.textAlignment = NSTextAlignment.center
        Label.backgroundColor = UIColor.white
        Label.font = FONT_SIZE
        Label.textColor = LABEL_COLOR

        return Label
    }
    
    private func createMessageTextView() -> UITextView {
        let textView = UITextView(frame: CGRect.zero)
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.font = FONT_SIZE
        textView.textColor = UIColor.darkText
        textView.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        return textView
    }
    
    private func createDatePicker() -> UIDatePicker {
        let datePickerView = UIDatePicker(frame: CGRect.zero)
        datePickerView.backgroundColor = UIColor.init(white: 0.9, alpha: 0.6)
        datePickerView.datePickerMode = .date
        datePickerView.date = self.datePickerStartDate
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
//        datePickerView.setValue(App_color, forKey: "textColor")
       // datePickerView.minimumDate = EventHelper().minTravelDate()
//        datePickerView.maximumDate =  RootUtils.dateByAddingDays(days: 731, date:Date())
        
        datePickerView.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)

        return datePickerView
    }
    
    func addSeprator(frame:CGRect) -> UILabel {
        let sepratorLbl = UILabel(frame: frame)
        sepratorLbl.backgroundColor = UIColor.gray
        
        return sepratorLbl
    }
    
    func createButtonWithTag(_ title:String,_ tag:Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = FONT_SIZE
        button.tintColor = UIColor.blue
        button.backgroundColor = UIColor.white
        button.tag = tag
        button.addTarget(self, action: #selector(AlertBox.buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    func roundCorners(view: UIView, corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners:corners, cornerRadii: CGSize(width: kCornerRadius, height: kCornerRadius))
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
    
    open func show() {
        let bounceAnimation = CAKeyframeAnimation.init(keyPath: "transform.scale")
        bounceAnimation.values = [0.5, 1.1, 0.8, 1.0]
        bounceAnimation.duration = 0.3
        bounceAnimation.isRemovedOnCompletion = true
        alertBoxView.layer.add(bounceAnimation, forKey: "bounce")
        
        if tapToDismiss {
            let tap = UITapGestureRecognizer(target: self, action: #selector(AlertBox.dismiss(_:)))
            tap.delegate = self
            backgroundView.addGestureRecognizer(tap)
        }
        
        let rootView = UIApplication.shared.keyWindow
        
        let containingFrame = rootView?.bounds
        backgroundView.frame = containingFrame!
        self.alpha = 0
        layoutIfNeeded()
        rootView?.addSubview(backgroundView)
        
    }
    
    //MARK:- SELECTORS
    @objc func dismiss(_ sender: UITapGestureRecognizer? = nil) {
        
        UIView.animate(withDuration: 0.15, animations: {
            self.alertBoxView.frame.origin.y += self.backgroundView.bounds.maxY
        }, completion: { (success:Bool) in
            
            UIView.animate(withDuration: 0.05, delay: 0, options: .transitionCrossDissolve, animations: {
                self.backgroundView.alpha = 0
            }, completion: { (success:Bool) in
                self.backgroundView.removeGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(AlertBox.dismiss(_:))))
                self.backgroundView.removeFromSuperview()
                self.removeFromSuperview()
            })
            
        })
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if delegate != nil {
            if self.datePickerView != nil {
                self.delegate?.alertBoxDidSelect(alertBox: self, buttonIndex: sender.tag, date: datePickerView.date)
            } else {
                self.delegate?.alertBoxDidSelect(alertBox: self, buttonIndex: sender.tag, date: nil)
            }
            self.dismiss()
        }
    }
    
    @objc func didChangeValue(_ sender: UIButton) {
        if self.datePickerView.datePickerMode.rawValue == 0 {
            titleLabel.text = dateToString(self.datePickerView.date, TIME_FORMATE)
        } else {
            titleLabel.text = picketTitleFormate(date: self.datePickerView.date)
        }
    }

    
    //MARK:- VIEW LAYOUTS
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let screenWidth = UIScreen.main.bounds.width

        if (screenWidth > 375) // alertView fix for iPad / Plus Devices
        {
         ALERT_BOX_MARGIN = (UIScreen.main.bounds.width - 345.0)/2
         ALERT_BOX_WIDTH = 345.0
        }
        
        alertBoxView.frame = CGRect(x: ALERT_BOX_MARGIN, y: ALERT_BOX_Y_OFFSET, width: ALERT_BOX_WIDTH, height: ALERT_BOX_HEIGHT)
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: ALERT_BOX_WIDTH, height: TITLE_LABEL_HEIGHT)
        roundCorners(view: titleLabel, corners: [.topRight, .topLeft])
        
        topSeprator.frame = CGRect(x: 0, y: TITLE_LABEL_HEIGHT, width: ALERT_BOX_WIDTH, height: SEPRATOR_HEIGHT)

        var yPos = TITLE_LABEL_HEIGHT + SEPRATOR_HEIGHT

        if ((datePickerView) != nil) {
        messageTextView.frame = CGRect(x: 0, y: yPos, width: ALERT_BOX_WIDTH, height: 46)
        
        datePickerView.frame = CGRect(x: 0, y: messageTextView.frame.maxY, width: ALERT_BOX_WIDTH, height: 216)
        yPos = datePickerView.frame.maxY
        } else {
            messageTextView.frame = CGRect(x: 0, y: yPos, width: ALERT_BOX_WIDTH, height: 170)
            yPos = messageTextView.frame.maxY
            alertBoxView.frame.size.height = yPos + BUTTON_HEIGHT + SEPRATOR_HEIGHT
        }
        bottomSeprator.frame = CGRect(x: 0, y: yPos, width: ALERT_BOX_WIDTH, height: SEPRATOR_HEIGHT)
        
        if (closeButton != nil) {
            doneButton.frame = CGRect(x: (ALERT_BOX_WIDTH/2) + 1 , y: yPos+SEPRATOR_HEIGHT, width: (ALERT_BOX_WIDTH/2) - 1, height: BUTTON_HEIGHT)
            roundCorners(view: doneButton, corners: [.bottomRight])
            
            closeButton.frame = CGRect(x: 0, y: yPos + SEPRATOR_HEIGHT, width: ALERT_BOX_WIDTH/2, height: BUTTON_HEIGHT)
            roundCorners(view: closeButton, corners: [.bottomLeft])
        } else {
            doneButton.frame = CGRect(x: 0 , y: yPos + SEPRATOR_HEIGHT, width: ALERT_BOX_WIDTH, height: BUTTON_HEIGHT)
            roundCorners(view: doneButton, corners: [.bottomRight, .bottomLeft])
        }

    }
    
    //MARK:- HELPERS
    private func pickerTypeAsTime(date: String)  {
        self.tapToDismiss = false
        self.datePickerView.datePickerMode = .time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  TIME_FORMATE
        
        self.datePickerView.date = dateFormatter.date(from: date)!
        self.titleLabel.text = dateToString(self.datePickerView.date, TIME_FORMATE)
        self.datePickerView.minimumDate = nil
        self.datePickerView.minimumDate = nil
    }
   
    private func picketTitleFormate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        let weekDay = Calendar(identifier: Calendar.Identifier.gregorian).component(.weekday, from: date)
        let shortweek = dateFormatter.shortWeekdaySymbols[weekDay - 1]
        
        return "\(shortweek)" + ", " + dateToString(date, DATE_FORMATE)
    }
    
    private func dateToString(_ date: Date?,_ formate:String) ->String {
        let formatter = DateFormatter()
        formatter.dateFormat = formate
        formatter.timeZone = TimeZone.current
        
        guard (date != nil) else{
            return ""
        }
        return formatter.string(from: date!)
    }

}




