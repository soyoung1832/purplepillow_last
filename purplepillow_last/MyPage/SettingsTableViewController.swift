import UIKit
import FirebaseAuth  // Firebase 인증 라이브러리 import

class SettingsTableViewController: UITableViewController {
   
   // 섹션과 셀 데이터
   let sections = ["계정", "알림", "기타"]
   let accountOptions = ["프로필 편집", "비밀번호 변경"]
   let notificationOptions = ["알림 설정"]
   let otherOptions = ["로그아웃"]
   
   override func viewDidLoad() {
       super.viewDidLoad()
   }
   
   // 섹션 내 셀 수 반환
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       switch section {
       case 0:
           return accountOptions.count
       case 1:
           return notificationOptions.count
       case 2:
           return otherOptions.count
       default:
           return 0
       }
   }
   
   // 섹션 수 반환
   override func numberOfSections(in tableView: UITableView) -> Int {
       return sections.count
   }
   
   // 섹션 제목 설정
   override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return sections[section]
   }
   
   // 테이블 셀 설정
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // MyCustomTableViewCell로 셀을 생성합니다.
        let cell = MyCustomTableViewCell(style: .default, reuseIdentifier: "Cell")

        // 셀 설정
        switch indexPath.section {
        case 0:
            cell.configure(withTitle: accountOptions[indexPath.row])
        case 1:
            cell.configure(withTitle: notificationOptions[indexPath.row])
        case 2:
            cell.configure(withTitle: otherOptions[indexPath.row])
        default:
            break
        }

        return cell
    }
   
   // 셀 선택 시 처리
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       if indexPath.section == 2 && indexPath.row == 0 {
           // "로그아웃" 셀이 선택된 경우 로그아웃 동작 수행
           logout()
       }
   }
   
   // 로그아웃 동작을 수행하는 함수
   func logout() {
       do {
           try Auth.auth().signOut()  // Firebase에서 사용자 로그아웃
           // 로그아웃 성공, 로그인 화면으로 이동
           if let loginViewController = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
               // "LoginViewController"는 로그인 화면의 스토리보드 식별자입니다.
               // 이 식별자는 사용자의 프로젝트 구성에 따라 다를 수 있습니다.
               navigationController?.setViewControllers([loginViewController], animated: true)
           }
       } catch let signOutError as NSError {
           print("Error signing out: \(signOutError.localizedDescription)")
           // 로그아웃 실패, 에러 처리
       }
   }
}
