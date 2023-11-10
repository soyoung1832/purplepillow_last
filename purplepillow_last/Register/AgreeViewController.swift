import UIKit

class AgreeViewController: UIViewController {
    
    @IBOutlet weak var checkAllBtn: UIButton!
    @IBOutlet weak var checkBtn1: UIButton!
    @IBOutlet weak var checkBtn2: UIButton!
    @IBOutlet weak var nextBtn: UIButton!

    // 모든 check 버튼이 선택되었는지 여부를 추적
    private var allCheckButtonsSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // checkAllBtn 누를 때
        checkAllBtn.addTarget(self, action: #selector(checkAllButtonTapped), for: .touchUpInside)
        
        // check 버튼들의 초기 이미지 설정
        checkAllBtn.setImage(UIImage(named: "check_off"), for: .normal)
        checkBtn1.setImage(UIImage(named: "check_off"), for: .normal)
        checkBtn2.setImage(UIImage(named: "check_off"), for: .normal)
        
        // check 버튼 누를 때
        checkBtn1.addTarget(self, action: #selector(checkButton1Tapped), for: .touchUpInside)
        checkBtn2.addTarget(self, action: #selector(checkButton2Tapped), for: .touchUpInside)
        
        // 초기 상태에서 next 버튼 비활성화
        nextBtn.isEnabled = false
        nextBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        let logoImageView = UIImageView(image: UIImage(named: "PurplePillow"))
        logoImageView.contentMode = .scaleAspectFit // 이미지가 크기에 맞게 비율 유지하도록 설정
        logoImageView.frame = CGRect(x: 0, y: 0, width: logoImageView.image?.size.width ?? 0, height: logoImageView.image?.size.height ?? 0)
        logoImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.7) // 이미지 크기를 0.5배로 축소
        navigationItem.titleView = logoImageView

        
    }
    
    @objc func checkAllButtonTapped() {
        allCheckButtonsSelected.toggle()
        checkAllBtn.setImage(UIImage(named: allCheckButtonsSelected ? "check_on" : "check_off"), for: .normal)
        checkBtn1.setImage(UIImage(named: allCheckButtonsSelected ? "check_on" : "check_off"), for: .normal)
        checkBtn2.setImage(UIImage(named: allCheckButtonsSelected ? "check_on" : "check_off"), for: .normal)
        updateNextButtonState()
    }
    
    @objc func checkButton1Tapped() {
        
        allCheckButtonsSelected = checkBtn1.isSelected && checkBtn2.isSelected
        
        // 각 check 버튼을 눌렀을 때 이미지 변경
        checkBtn1.setImage(UIImage(named: checkBtn1.isSelected ? "check_off" : "check_on"), for: .normal)
        checkBtn1.isSelected.toggle()
        // 모든 check 버튼이 선택되었는지 확인

        
        // next 버튼 상태 업데이트
        updateNextButtonState()
    }
    
    @objc func checkButton2Tapped() {
        // 각 check 버튼을 눌렀을 때 이미지 변경
        allCheckButtonsSelected = checkBtn1.isSelected && checkBtn2.isSelected
        
        checkBtn2.setImage(UIImage(named: checkBtn2.isSelected ? "check_off" : "check_on"), for: .normal)
        checkBtn2.isSelected.toggle()
        
        // 모든 check 버튼이 선택되었는지 확인
  
        // next 버튼 상태 업데이트
        updateNextButtonState()
    }
    // next 버튼의 상태를 업데이트
    func updateNextButtonState() {
        nextBtn.isEnabled = allCheckButtonsSelected
        nextBtn.setTitleColor(allCheckButtonsSelected ? UIColor.black : UIColor.lightGray, for: .normal)
    }
}
