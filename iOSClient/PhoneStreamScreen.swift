// Mochi's screen-first iPhone workspace. The iPad keeps its laptop-style controls.
import SwiftUI
import StreamProtocol

struct PhoneStreamScreen: View {
    @ObservedObject var client: StreamClient
    @Binding var drawerOpen: Bool
    @Binding var keyboardShown: Bool
    @Binding var textScale: Double?
    @Binding var windowMenu: UInt32?
    @Binding var latched: KeyModifiers
    let overlay: InputOverlayProxy
    let settingsOpen: Bool
    let setSettings: (Bool, Bool) -> Void
    let menusOpened: () -> Void
    let menusClosed: () -> Void
    let onPanelSize: (CGSize) -> Void
    let pairThisDevice: () -> Void
    let linkLine: String?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var padShown = false
    @State private var toolsShown = false
    @State private var helpShown = false
    @State private var reading = false
    @State private var zoom: CGFloat = 1
    @State private var pan = CGSize.zero
    @GestureState private var pinch: CGFloat = 1
    @GestureState private var drag = CGSize.zero

    private var motion: Animation? { reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 1) }
    private var title: String {
        if case .window(let id) = client.active {
            return client.windows.first(where: { $0.id == id })?.title ?? "App window"
        }
        return "Mac desktop"
    }
    private var showingPanel: Bool { drawerOpen || settingsOpen || toolsShown }

    var body: some View {
        GeometryReader { geo in
            let sideways = geo.size.width > geo.size.height
            VStack(spacing: 6) {
                if !sideways {
                    HStack(spacing: 8) {
                        Image(systemName: "leaf.fill").foregroundStyle(Palette.accent)
                        Text(title).lineLimit(1)
                        Spacer(minLength: 0)
                        Text(reading ? "READ" : "CONTROL")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .tracking(1)
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Palette.text)
                    .padding(.horizontal, 14)
                    .frame(height: 28)
                }

                ZStack(alignment: .bottom) {
                    canvas
                    if showingPanel {
                        Color.black.opacity(0.18)
                            .contentShape(Rectangle())
                            .onTapGesture { closePanels() }
                            .accessibilityHidden(true)
                        panel(compact: sideways)
                            .padding(8)
                            .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

                if keyboardShown {
                    KeyRow(metrics: .phone, keys: .phone, latched: $latched,
                           keyboardShown: keyboardShown, send: client.sendFromKeyRow,
                           toggleKeyboard: { overlay.toggleKeyboard() }, showSpotlight: client.active == .desktop)
                        .padding(.horizontal, 10)
                }
                if padShown && !keyboardShown && !showingPanel {
                    Trackpad(send: client.sendInput,
                             setPointer: { client.setOwnPointer($0, from: .trackpad) },
                             feed: { let f = client.pointerFeedState; return (f.anchor, f.reseeds) },
                             onFingers: client.trackpadFingers, latched: latched,
                             onModifiersConsumed: { latched = [] },
                             verticalSpan: PhoneCanvasGeometry.trackpadSpan(width: geo.size.width - 20, video: client.videoSize),
                             sendGesture: { client.sendGesture($0, fingers: $1) })
                        .frame(height: sideways ? 90 : 140)
                        .padding(.horizontal, 10)
                }
                toolbar
                    .padding(.horizontal, 8)
            }
            .padding(.top, 4)
            .padding(.bottom, keyboardShown ? 4 : max(geo.safeAreaInsets.bottom, sideways ? 12 : 24))
            .background(Palette.background)
        }
        .onAppear {
            // Fit selected windows to the available viewport; desktop capture is unaffected.
            if textScale == nil { textScale = 1 }
        }
        .onChange(of: client.active) { _, _ in resetView(); toolsShown = false }
        .onChange(of: client.videoSize) { _, _ in resetView() }
        .onChange(of: drawerOpen) { _, open in if open { toolsShown = false; overlay.setKeyboard(shown: false) } }
        .onChange(of: settingsOpen) { _, open in if open { toolsShown = false } }
        .sheet(isPresented: $helpShown) { help }
    }

    private var canvas: some View {
        GeometryReader { geo in
            let scale = min(4, max(1, zoom * pinch))
            let offset = PhoneCanvasGeometry.clamp(
                CGSize(width: pan.width + drag.width, height: pan.height + drag.height),
                viewport: geo.size, video: client.videoSize, zoom: scale)
            ZStack {
                Palette.panel
                ZStack {
                    StreamView(client: client)
                    InputOverlay(videoSize: client.videoSize, send: client.sendInput,
                                 setOwnPointer: { client.setOwnPointer($0, from: $1) },
                                 proxy: overlay, isKeyboardShown: $keyboardShown,
                                 latchedModifiers: latched, onModifiersConsumed: { latched = [] },
                                 sendGesture: { client.sendGesture($0, fingers: $1) })
                        // Reading gestures never send clicks or scrolling to the Mac.
                        .allowsHitTesting(!reading && !showingPanel)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(scale)
                .offset(offset)
                .accessibilityHidden(reading || showingPanel)

                if reading {
                    Color.clear.contentShape(Rectangle())
                        .gesture(MagnifyGesture().updating($pinch) { value, state, _ in state = value.magnification }
                            .onEnded { value in
                                zoom = min(4, max(1, zoom * value.magnification))
                                pan = PhoneCanvasGeometry.clamp(pan, viewport: geo.size, video: client.videoSize, zoom: zoom)
                            })
                        .simultaneousGesture(DragGesture(minimumDistance: 3)
                            .updating($drag) { value, state, _ in state = value.translation }
                            .onEnded { value in
                                pan = PhoneCanvasGeometry.clamp(
                                    CGSize(width: pan.width + value.translation.width, height: pan.height + value.translation.height),
                                    viewport: geo.size, video: client.videoSize, zoom: zoom)
                            })
                        .accessibilityLabel("Magnified Mac screen")
                        .accessibilityHint("Use the zoom buttons, or pinch and drag to explore. Choose Control to interact with the Mac.")
                }
            }
            .clipped()
            .overlay(alignment: .top) { LinkLineView(text: linkLine) }
            .overlay(alignment: .bottom) {
                if reading && !showingPanel {
                    HStack(spacing: 4) {
                        zoomButton("Zoom out", symbol: "minus.magnifyingglass") { changeZoom(zoom / 1.25, size: geo.size) }
                        Button("Fit") { resetView() }.frame(minWidth: 44, minHeight: 44)
                            .accessibilityLabel("Fit the entire picture")
                        Text("\(Int(scale * 100))%")
                            .font(.caption.monospacedDigit()).frame(minWidth: 42)
                        zoomButton("Zoom in", symbol: "plus.magnifyingglass") { changeZoom(zoom * 1.25, size: geo.size) }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Palette.text)
                    .background(Palette.bar, in: Capsule())
                    .padding(8)
                }
            }
            .onChange(of: geo.size, initial: true) { _, size in
                onPanelSize(size)
                pan = PhoneCanvasGeometry.clamp(pan, viewport: size, video: client.videoSize, zoom: zoom)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .tourTarget(.stream)
        .padding(.horizontal, 6)
    }

    private var toolbar: some View {
        HStack(spacing: 4) {
            tool("Apps", symbol: "square.grid.2x2", selected: drawerOpen) {
                let open = !drawerOpen
                closePanels(); overlay.setKeyboard(shown: false)
                withAnimation(motion) { drawerOpen = open }
            }
            tool("Keyboard", symbol: keyboardShown ? "keyboard.chevron.compact.down" : "keyboard", selected: keyboardShown) {
                closePanels(); reading = false; overlay.toggleKeyboard()
            }
            tool("Trackpad", symbol: "rectangle.and.hand.point.up.left", selected: padShown) {
                closePanels(); overlay.setKeyboard(shown: false)
                withAnimation(motion) { padShown.toggle() }
            }
            tool(reading ? "Control" : "Zoom", symbol: reading ? "cursorarrow" : "plus.magnifyingglass", selected: reading) {
                closePanels(); overlay.setKeyboard(shown: false)
                reading.toggle()
                if reading && zoom == 1 { zoom = 2 }
            }
            tool("More", symbol: "ellipsis", selected: toolsShown || settingsOpen) {
                let open = !toolsShown
                closePanels(); overlay.setKeyboard(shown: false)
                withAnimation(motion) { toolsShown = open }
            }
        }
        .frame(height: 52)
    }

    private func tool(_ title: String, symbol: String, selected: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: symbol).font(.system(size: 19, weight: .medium)).frame(height: 23)
                Text(title).font(.system(size: 10, weight: .medium)).lineLimit(1).minimumScaleFactor(0.8)
            }
            .foregroundStyle(selected ? Palette.onAccent : Palette.text)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(selected ? Palette.accent : Color.clear, in: RoundedRectangle(cornerRadius: 13))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityShowsLargeContentViewer { Label(title, systemImage: symbol) }
    }

    @ViewBuilder private func panel(compact: Bool) -> some View {
        if settingsOpen {
            HostSettingsPanel(client: client, close: { setSettings(false, true) },
                              pairThisDevice: pairThisDevice, takeTour: { setSettings(false, false); helpShown = true })
                .frame(maxWidth: 420, maxHeight: .infinity, alignment: .bottom)
        } else if drawerOpen {
            VStack(spacing: 6) {
                HStack {
                    Text("Apps & windows").font(.headline)
                    Spacer()
                    Button("Done") { closePanels() }.frame(minHeight: 44)
                }.padding(.horizontal, 12)
                if !compact {
                    WindowStrip(client: client, width: 100, height: 62, radius: 9, spacing: 12,
                                pad: 8, fade: 0.88, badge: 22, menuFor: $windowMenu)
                        .frame(height: 82)
                }
                AppDrawer(client: client, drawerOpen: $drawerOpen)
            }
            .foregroundStyle(Palette.text)
            .background(Palette.bar, in: RoundedRectangle(cornerRadius: 18))
            .frame(maxWidth: 420)
        } else if toolsShown {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Workspace").font(.headline)
                        Spacer()
                        Button("Done") { closePanels() }.frame(minHeight: 44)
                    }
                    HStack(spacing: 8) {
                        tool("Desktop", symbol: "desktopcomputer") { client.select(.desktop); closePanels() }
                        if client.menus.hasMenus {
                            MacMenuButton(client: client, width: 64, height: 48, radius: 12,
                                          iconSize: 18, spacing: 2, onOpen: menusOpened, onClose: menusClosed)
                        }
                        tool("Settings", symbol: "gearshape") { toolsShown = false; setSettings(true, true) }
                        tool("Help", symbol: "questionmark.circle") { closePanels(); helpShown = true }
                    }
                    if case .window = client.active {
                        Text("App text size").font(.subheadline.weight(.medium))
                        Picker("App text size", selection: Binding(get: { textScale ?? 1 }, set: { textScale = $0 })) {
                            Text("Small").tag(0.75)
                            Text("Default").tag(1.0)
                            Text("Large").tag(1.25)
                            Text("Larger").tag(1.5)
                        }.pickerStyle(.segmented)
                        Text("Fits this app’s window to your phone. Some Mac apps have a minimum window width.")
                            .font(.caption).foregroundStyle(Palette.muted)
                    }
                    Text("Shortcut keys").font(.subheadline.weight(.medium))
                    KeyRow(metrics: .phone, keys: .phone, latched: $latched,
                           keyboardShown: keyboardShown, send: client.sendFromKeyRow,
                           toggleKeyboard: { overlay.toggleKeyboard() }, showSpotlight: client.active == .desktop)
                }
                .padding(14)
            }
            .frame(maxWidth: 420, maxHeight: 330)
            .background(Palette.bar, in: RoundedRectangle(cornerRadius: 18))
        }
    }

    private var help: some View {
        NavigationStack {
            List {
                Label("Choose an app in Apps. Tap an open app again to switch to its next window.", systemImage: "square.grid.2x2")
                Label("Zoom opens reading mode: pinch to magnify and drag to explore. Control lets you click the magnified picture.", systemImage: "plus.magnifyingglass")
                Label("Turn your iPhone sideways for a wider view of your Mac.", systemImage: "iphone.gen3.radiowaves.left.and.right")
                Label("Open Trackpad for precise pointer control. Keyboard reveals typing and shortcut keys.", systemImage: "keyboard")
                Label("More contains Desktop, Mac menus, text size and Settings.", systemImage: "ellipsis")
            }
            .navigationTitle("Mochi on iPhone")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { helpShown = false } } }
        }
        .tint(Palette.accent)
    }

    private func closePanels() {
        withAnimation(motion) { drawerOpen = false; toolsShown = false }
        if settingsOpen { setSettings(false, false) }
        windowMenu = nil
    }
    private func resetView() { zoom = 1; pan = .zero }
    private func changeZoom(_ value: CGFloat, size: CGSize) {
        zoom = min(4, max(1, value))
        pan = PhoneCanvasGeometry.clamp(pan, viewport: size, video: client.videoSize, zoom: zoom)
    }
    private func zoomButton(_ label: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(systemName: symbol).frame(width: 44, height: 44) }
            .accessibilityLabel(label)
    }
}
