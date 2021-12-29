//
//  MainViewController.swift
//  IOS-FinalProject-LSBank
//
//  Created by user203175 on 10/19/21.
//

import UIKit

class MainViewController: UIViewController, BalanceRefresh, UITableViewDelegate, UITableViewDataSource {

    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var recentTransanctions : [TransactionsStatementTransaction] = []
    
    @IBOutlet weak var vBtnWithdraw : UIView!
    @IBOutlet weak var vBtnDeposit : UIView!
    @IBOutlet weak var vBtnTransfer : UIView!
    
    @IBOutlet weak var lblUsername : UILabel!
    @IBOutlet weak var lblBalance : UILabel!
    
    @IBOutlet weak var btnRefreshBalance : UIButton!
    
    //---//
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblRecentTransaction: UILabel!
    var refreshControl = UIRefreshControl()
    //---//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initialize()
        
        lblUsername.text = "Hi \(LoginViewController.account!.firstName)"
        
        refreshBalance()

    }
    
    private func initialize(){
        customizeView()
        
        refreshControl.addTarget(self, action: #selector(tableRefreshControl), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.register(TransactionTableViewCell.nib(), forCellReuseIdentifier: TransactionTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    private func customizeView() {
        vBtnWithdraw.setLayerCornerRadius(MyAppDefaults.LayerCornerRadius.button)
        vBtnDeposit.setLayerCornerRadius(MyAppDefaults.LayerCornerRadius.button)
        vBtnTransfer.setLayerCornerRadius(MyAppDefaults.LayerCornerRadius.button)
    }
    
    
    @IBAction func btnLogOff(_ sender: Any) {
        
        let btnYes = Dialog.DialogButton(title: "Yes", style: .default, handler: {action in
            self.navigationController?.popViewController(animated: true)
        })
        let btnNo = Dialog.DialogButton(title: "No", style: .destructive, handler: nil)
        
        Dialog.show(view: self, title: "Login off", message: "\(LoginViewController.account!.firstName), are you sure you want to leave?", style: .actionSheet, completion: nil, presentAnimated: true, buttons: btnYes, btnNo)
        
    }
    
    
    
    func refreshBalanceSuccess(httpStatusCode : Int, response : [String:Any] ){
        
        DispatchQueue.main.async {
            self.btnRefreshBalance.isEnabled = true
            self.lblBalance.text = "?"
        }
        
        if httpStatusCode == 200 {
            
            if let accountBalance = AccountsBalance.decode(json: response){
                
                DispatchQueue.main.async {
                    self.lblBalance.text = "CAD$ " + accountBalance.balance.formatAsCurrency()
                }
                
            }
        } else {
            DispatchQueue.main.async {
                Toast.show(view: self, title: "Something went wrong!", message: "Error parsing data received from server! Try again!")
            }
        }
        
    }
    
    
    func refreshBalanceFail( httpStatusCode : Int, message : String ){
        
        DispatchQueue.main.async {
            self.lblBalance.text = ""
            self.btnRefreshBalance.isEnabled = true
            Toast.show(view: self, title: "Ooops!", message: message)
        }
        
    }
    
    
    
    func refreshBalance() {
        
        lblBalance.text = "wait..."

        LSBankAPI.accountBalance(token: LoginViewController.token, successHandler: refreshBalanceSuccess, failHandler: refreshBalanceFail)
        
        refreshRecentTransanctions()
        
    }
    
    
    func refreshRecentTransanctions() {
        LSBankAPI.statement(token: LoginViewController.token, days: 30, successHandler: refreshRecentTransanctionsSuccess, failHandler: refreshRecentTransanctionsFail)
        
    }
    
    
    func refreshRecentTransanctionsSuccess(httpStatusCode : Int, response : [String:Any] ) {
        
        DispatchQueue.main.async {

        }
        
        if httpStatusCode == 200 {
            
            if let transactions = TransactionStatement.decode(json: response){
                
                DispatchQueue.main.async {
                    
                    self.recentTransanctions = transactions.statement
                    
                    if self.recentTransanctions.count == 0 {
                        self.lblRecentTransaction.text = "No recent transaction"
                    } else if self.recentTransanctions.count == 1 {
                        self.lblRecentTransaction.text = "1 recent transaction"
                    } else {
                        self.lblRecentTransaction.text = "\(self.recentTransanctions.count) recent transactions"
                    }
                    
                    self.tableView.reloadData()
                    
                }
                
            }
        } else {
            DispatchQueue.main.async {
                Toast.show(view: self, title: "Something went wrong!", message: "Error parsing data received from server! Try again!")
            }
        }
        
    }
    
    
    func refreshRecentTransanctionsFail(httpStatusCode : Int, message : String) {
        
        DispatchQueue.main.async {
            
            Toast.show(view: self, title: "Ooops!", message: message)
        }
        
    }
    
    @objc func tableRefreshControl(send : UIRefreshControl) {
        
        DispatchQueue.main.async {
            
            self.refreshTable()
            self.refreshControl.endRefreshing()
        }
        
    }
    
    
    private func refreshTable() {

        refreshBalance()
        refreshRecentTransanctions()
        
    }
    
    
    @IBAction func btnRefreshBalanceTouchUp(_ sender : Any? ) {
        
        btnRefreshBalance.isEnabled = false
        refreshBalance()
        
    }
    
    @IBAction func btnPayeeTouchUp(_ sender : Any? ) {
        
        performSegue(withIdentifier: Segue.toPayeesView, sender: nil)
        
    }
    
    @IBAction func btnSendMoneyTouchUp(_ sender : Any? ){
        
        if Payee.all(context: self.context).count == 0 {
            Toast.ok(view: self, title: "No payees", message: "Please, set your payees list before sending money!")
            return
        }
        
        
        performSegue(withIdentifier: Segue.toSendMoneyView, sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.toSendMoneyView {
            
            (segue.destination as! SendMoneyViewController).payeeList = Payee.allByFirstName(context: self.context)
            (segue.destination as! SendMoneyViewController).delegate = self
            
            
        }
        
    }
    
    func balanceRefresh() {
        // BalanceRefresh protocol stub
        self.refreshBalance()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if self.recentTransanctions.count == 0 {
//            self.lblRecentTransaction.text = "No recent transaction"
//        } else if self.recentTransanctions.count == 1 {
//            self.lblRecentTransaction.text = "1 recent transaction"
//        } else {
//            self.lblRecentTransaction.text = "\(self.recentTransanctions.count) recent transactions"
//        }
        
        return self.recentTransanctions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as! TransactionTableViewCell
        
        let transanction = self.recentTransanctions[self.recentTransanctions.count - 1 - indexPath.row]
        
        var credit : Bool = false
        var accountHolder : String = ""
        
        if (LoginViewController.account!.accountId.contains(transanction.fromAccount!.accountId)) {
            
            accountHolder = "\(transanction.toAccount!.firstName.uppercased()),\(transanction.toAccount!.lastName.uppercased())"
            credit = false //debit
            
            
        } else {
            
            accountHolder = "\(transanction.fromAccount!.firstName.uppercased()),\(transanction.fromAccount!.lastName.uppercased())"
            credit = true //credit
            
        }
        
        cell.setCellContent(accountHolder: accountHolder, dateTime: transanction.dateTime, amount: transanction.amount, credit: credit, messages: transanction.message)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.recentTransanctions[self.recentTransanctions.count - 1 - indexPath.row].message.count == 0 {
            return 70
        }
        return 95
    }
    
    
}
