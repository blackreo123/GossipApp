# 5초 뒷담화 📢

> 익명으로 일상 속 작은 불만이나 생각을 털어놓고, 5초 후 자동으로 사라지는 실시간 소통 앱

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![Tuist](https://img.shields.io/badge/Tuist-4.65.0-green.svg)](https://tuist.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## ✨ 주요 기능

- 🕵️ **완전 익명**: 사용자 식별 불가능, 개인정보 수집 최소화
- ⏱️ **5초 자동 삭제**: 모든 뒷담화는 5초 후 자동으로 사라짐
- 📝 **일일 제한**: 하루 3회만 작성 가능 (스팸 방지)
- 🔄 **실시간 동기화**: 모든 사용자에게 실시간으로 공유
- 📱 **다크 모드**: 눈에 편안한 다크 인터페이스
- 🎯 **간단한 UX**: 직관적이고 미니멀한 사용자 경험

## 🏗 기술 스택

### iOS 앱
- **언어**: Swift 5.9+
- **UI 프레임워크**: SwiftUI
- **최소 지원 버전**: iOS 17.0+
- **프로젝트 관리**: Tuist 4.65.0
- **실시간 통신**: SocketIO
- **아키텍처**: MVVM + Clean Architecture

### 백엔드 서버 (별도 저장소)
- **런타임**: Node.js
- **프레임워크**: Express.js
- **실시간 통신**: Socket.IO
- **데이터베이스**: MongoDB
- **캐싱**: Redis

## 🚀 개발 환경 설정

### 사전 요구사항
- Xcode 15.0+
- macOS Sonoma 14.0+
- Tuist 4.65.0+
- Node.js 18+ (서버 실행용)

### 1. 저장소 클론
```bash
git clone https://github.com/yourusername/gossip-app-ios.git
cd gossip-app-ios
```

### 2. Tuist 설치 (처음 한 번만)
```bash
curl -Ls https://install.tuist.io | bash
```

### 3. 의존성 설치
```bash
tuist install
```

### 4. 프로젝트 생성 및 Xcode 실행
```bash
tuist generate
```

### 5. 서버 실행 (별도 터미널)
```bash
# 서버 저장소에서
git clone https://github.com/yourusername/gossip-app-server.git
cd gossip-app-server
npm install
npm start
```

## 📦 프로젝트 구조

```
GossipApp/
├── Project.swift                  # Tuist 프로젝트 정의
├── Tuist/
│   ├── Config.swift              # Tuist 설정
│   └── Package.swift             # 외부 의존성
├── GossipApp/                    # 메인 앱 타겟
│   ├── Sources/
│   │   ├── App/                  # 앱 진입점
│   │   ├── Views/                # SwiftUI 뷰
│   │   ├── Managers/             # 비즈니스 로직
│   │   └── Models/               # 데이터 모델
│   ├── Resources/                # 앱 리소스
│   └── Tests/                    # 유닛 테스트
├── GossipCore/                   # 코어 프레임워크
│   └── Sources/
│       ├── Models/               # 공통 데이터 모델
│       ├── Services/             # 서비스 인터페이스
│       └── Extensions/           # 확장 기능
└── Documentation/                # 프로젝트 문서
```

## 🔧 주요 Tuist 명령어

```bash
# 의존성 설치
tuist install

# 프로젝트 생성 + Xcode 실행
tuist generate

# 매니페스트 파일 편집
tuist edit

# 캐시 정리
tuist clean

# 프로젝트 구조 시각화
tuist graph
```

## 🧪 테스트 실행

### Xcode에서
```bash
# 키보드 단축키
Cmd + U
```

### 명령줄에서
```bash
xcodebuild test \
  -workspace GossipApp.xcworkspace \
  -scheme GossipApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## 📐 아키텍처 다이어그램

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   SwiftUI Views │────│  GossipManager  │────│   Socket.IO     │
│                 │    │                 │    │                 │
│ • ContentView   │    │ • 상태 관리       │    │ • 실시간 통신      │
│ • Components    │    │ • 네트워크 로직    │    │ • 이벤트 처리      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   GossipCore    │
                    │                 │
                    │ • 데이터 모델      │
                    │ • 비즈니스 로직    │
                    │ • 유틸리티        │
                    └─────────────────┘
```

## 🔍 API 명세

### WebSocket 이벤트

| 이벤트 | 방향 | 설명 |
|--------|------|------|
| `connect` | Client → Server | 서버 연결 |
| `gossip-display` | Server → Client | 뒷담화 표시 |
| `countdown` | Server → Client | 카운트다운 업데이트 |
| `new-gossip` | Server → Client | 새 뒷담화 알림 |

### REST API

| 메서드 | 엔드포인트 | 설명 |
|--------|------------|------|
| `POST` | `/api/gossip` | 뒷담화 작성 |
| `GET` | `/api/usage/:deviceId` | 사용량 조회 |

## 🎨 UI/UX 가이드라인

### 색상 팔레트
- **배경**: Linear Gradient (Black → Gray)
- **텍스트**: White / White.opacity(0.7)
- **액센트**: White (버튼 배경)
- **상태**: Green (연결됨) / Red (연결 안됨)

### 타이포그래피
- **메인 텍스트**: `.title2`, `weight: .medium`
- **카운트다운**: `.caption`
- **버튼**: `.body`, `weight: .semibold`

### 애니메이션
- **뒷담화 등장**: Slide up + Fade in
- **뒷담화 사라짐**: Fade out
- **모드 전환**: Spring animation

## 🔒 개인정보 및 보안

- ✅ 개인정보 수집 최소화 (디바이스 UUID만 사용)
- ✅ 모든 뒷담화는 5초 후 자동 삭제
- ✅ 서버에 개인정보 저장하지 않음
- ✅ HTTPS 통신 (프로덕션 환경)
- ✅ 콘텐츠 필터링 시스템 (예정)

## 🤝 기여하기

1. 이 저장소를 포크합니다
2. 기능 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋합니다 (`git commit -m '✨ Add amazing feature'`)
4. 브랜치에 푸시합니다 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성합니다

### 커밋 메시지 규칙
```
✨ feat: 새 기능 추가
🐛 fix: 버그 수정
📚 docs: 문서 수정
🎨 style: 코드 포맷팅
🔥 refactor: 코드 리팩토링
🧪 test: 테스트 추가
🔧 chore: 기타 작업
```

## 📋 개발 로드맵

### Version 1.0 (MVP) ✅
- [x] 기본 뒷담화 작성/표시
- [x] 5초 자동 삭제
- [x] 일일 사용 제한 (3회)
- [x] 실시간 동기화
- [x] 다크모드 UI

### Version 1.1 (계획)
- [ ] 신고 기능
- [ ] 콘텐츠 필터링
- [ ] 푸시 알림
- [ ] 앱 아이콘 및 스플래시

### Version 1.2 (계획)
- [ ] 지역 기반 필터링
- [ ] 사용량 통계
- [ ] 접근성 개선
- [ ] iPad 지원

## 🐛 알려진 이슈

- [ ] 시뮬레이터에서 Socket 연결이 간헐적으로 실패하는 문제
- [ ] 백그라운드 진입 시 재연결 로직 개선 필요
- [ ] 긴 텍스트 입력 시 레이아웃 깨짐 (50자 제한으로 해결)

## 📜 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 📞 연락처

- **개발자**: [blackreo123](mailto:blackreo123@gmail.com)
- **프로젝트 링크**: [https://github.com/blackreo123/gossip-app-ios](https://github.com/blackreo123/gossip-app-ios)
- **서버 저장소**: [https://github.com/blackreo123/gossip-app-server](https://github.com/blackreo123/gossip-app-server)

## 🙏 감사의 말

- [Tuist](https://tuist.io/) - 훌륭한 Xcode 프로젝트 관리 도구
- [Socket.IO](https://socket.io/) - 실시간 통신 라이브러리
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - 현대적인 UI 프레임워크

---

<div align="center">
  <p>익명의 소통, 5초의 진실 💬</p>
  <p>Made with ❤️ in Swift</p>
</div>
