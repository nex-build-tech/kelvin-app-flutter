import React, { useState, useRef } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, StyleSheet,
  KeyboardAvoidingView, Platform, ScrollView, Animated,
  ActivityIndicator, Alert, Dimensions,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../context/AuthContext';
import { colors } from '../theme';

const { width } = Dimensions.get('window');

const DEMO_HINTS = [
  { label: 'Procurement Manager', email: 'suresh@kelvinmech.com', password: 'kelvin123' },
  { label: 'Project Manager',     email: 'priya@kelvinmech.com',  password: 'kelvin123' },
  { label: 'Admin',               email: 'admin@kelvinmech.com',  password: 'admin123'  },
  { label: 'Demo Viewer',         email: 'demo@kelvinmech.com',   password: 'demo'      },
];

export default function LoginScreen() {
  const { login, loginWithGoogle } = useAuth();
  const [email,       setEmail]       = useState('');
  const [password,    setPassword]    = useState('');
  const [showPwd,     setShowPwd]     = useState(false);
  const [loading,     setLoading]     = useState(false);
  const [googleLoad,  setGoogleLoad]  = useState(false);
  const [showHints,   setShowHints]   = useState(false);
  const shakeAnim = useRef(new Animated.Value(0)).current;
  const pwdRef    = useRef(null);

  const shake = () => {
    Animated.sequence([
      Animated.timing(shakeAnim, { toValue: 10,  duration: 60, useNativeDriver: true }),
      Animated.timing(shakeAnim, { toValue: -10, duration: 60, useNativeDriver: true }),
      Animated.timing(shakeAnim, { toValue: 6,   duration: 60, useNativeDriver: true }),
      Animated.timing(shakeAnim, { toValue: -6,  duration: 60, useNativeDriver: true }),
      Animated.timing(shakeAnim, { toValue: 0,   duration: 60, useNativeDriver: true }),
    ]).start();
  };

  const handleLogin = async () => {
    if (!email.trim() || !password.trim()) {
      shake();
      Alert.alert('Missing Fields', 'Please enter your email and password.');
      return;
    }
    setLoading(true);
    const res = await login(email.trim().toLowerCase(), password.trim());
    setLoading(false);
    if (!res.ok) {
      shake();
      Alert.alert('Login Failed', res.error || 'Invalid credentials. Try a demo account.');
    }
  };

  const handleGoogle = async () => {
    setGoogleLoad(true);
    await loginWithGoogle();
    setGoogleLoad(false);
  };

  const fillHint = (hint) => {
    setEmail(hint.email);
    setPassword(hint.password);
    setShowHints(false);
  };

  return (
    <LinearGradient
      colors={['#0A1F6E', '#1A56DB', '#0D2B8F']}
      style={styles.gradient}
      start={{ x: 0.1, y: 0 }}
      end={{ x: 0.9, y: 1 }}
    >
      {/* Background blobs */}
      <View style={styles.blob1} />
      <View style={styles.blob2} />

      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerStyle={styles.scroll}
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* Top logo area */}
          <View style={styles.logoArea}>
            <View style={styles.logoBox}>
              <Ionicons name="flash" size={36} color={colors.white} />
            </View>
            <Text style={styles.brand}>Kelvin Mech</Text>
            <Text style={styles.tagline}>MEP Operations Platform</Text>
          </View>

          {/* Card */}
          <Animated.View style={[styles.card, { transform: [{ translateX: shakeAnim }] }]}>
            <Text style={styles.cardTitle}>Welcome back</Text>
            <Text style={styles.cardSub}>Sign in to your workspace</Text>

            {/* Email */}
            <View style={styles.fieldWrap}>
              <Text style={styles.label}>Email Address</Text>
              <View style={styles.inputRow}>
                <Ionicons name="mail-outline" size={18} color={colors.gray400} style={styles.inputIcon} />
                <TextInput
                  style={styles.input}
                  placeholder="you@kelvinmech.com"
                  placeholderTextColor={colors.gray400}
                  autoCapitalize="none"
                  keyboardType="email-address"
                  returnKeyType="next"
                  value={email}
                  onChangeText={setEmail}
                  onSubmitEditing={() => pwdRef.current?.focus()}
                />
              </View>
            </View>

            {/* Password */}
            <View style={styles.fieldWrap}>
              <Text style={styles.label}>Password</Text>
              <View style={styles.inputRow}>
                <Ionicons name="lock-closed-outline" size={18} color={colors.gray400} style={styles.inputIcon} />
                <TextInput
                  ref={pwdRef}
                  style={[styles.input, { flex: 1 }]}
                  placeholder="••••••••"
                  placeholderTextColor={colors.gray400}
                  secureTextEntry={!showPwd}
                  returnKeyType="done"
                  value={password}
                  onChangeText={setPassword}
                  onSubmitEditing={handleLogin}
                />
                <TouchableOpacity onPress={() => setShowPwd(v => !v)} style={styles.eyeBtn}>
                  <Ionicons name={showPwd ? 'eye-off-outline' : 'eye-outline'} size={18} color={colors.gray400} />
                </TouchableOpacity>
              </View>
            </View>

            {/* Forgot */}
            <TouchableOpacity style={styles.forgotWrap}>
              <Text style={styles.forgotText}>Forgot password?</Text>
            </TouchableOpacity>

            {/* Login button */}
            <TouchableOpacity
              style={[styles.loginBtn, loading && styles.loginBtnDisabled]}
              onPress={handleLogin}
              disabled={loading}
              activeOpacity={0.85}
            >
              {loading
                ? <ActivityIndicator color={colors.white} />
                : <Text style={styles.loginBtnText}>Sign In</Text>
              }
            </TouchableOpacity>

            {/* Divider */}
            <View style={styles.divider}>
              <View style={styles.divLine} />
              <Text style={styles.divText}>or continue with</Text>
              <View style={styles.divLine} />
            </View>

            {/* Google */}
            <TouchableOpacity
              style={styles.googleBtn}
              onPress={handleGoogle}
              disabled={googleLoad}
              activeOpacity={0.85}
            >
              {googleLoad ? (
                <ActivityIndicator color={colors.primary} />
              ) : (
                <>
                  <View style={styles.googleIcon}>
                    <Text style={styles.googleG}>G</Text>
                  </View>
                  <Text style={styles.googleText}>Sign in with Google</Text>
                </>
              )}
            </TouchableOpacity>

            {/* Demo accounts hint */}
            <TouchableOpacity style={styles.demoToggle} onPress={() => setShowHints(v => !v)}>
              <Ionicons name="information-circle-outline" size={15} color={colors.primary} />
              <Text style={styles.demoToggleText}>Use a demo account</Text>
              <Ionicons name={showHints ? 'chevron-up' : 'chevron-down'} size={14} color={colors.primary} />
            </TouchableOpacity>

            {showHints && (
              <View style={styles.hintsBox}>
                {DEMO_HINTS.map((h, i) => (
                  <TouchableOpacity key={i} style={styles.hintRow} onPress={() => fillHint(h)}>
                    <View style={styles.hintAvatar}>
                      <Text style={styles.hintAvatarText}>{h.label[0]}</Text>
                    </View>
                    <View style={{ flex: 1 }}>
                      <Text style={styles.hintLabel}>{h.label}</Text>
                      <Text style={styles.hintEmail}>{h.email}</Text>
                    </View>
                    <Ionicons name="arrow-forward-circle-outline" size={20} color={colors.primary} />
                  </TouchableOpacity>
                ))}
              </View>
            )}
          </Animated.View>

          {/* Footer */}
          <Text style={styles.footer}>Powered by Ayu Ventures · v1.0.0</Text>
        </ScrollView>
      </KeyboardAvoidingView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  flex:             { flex: 1 },
  gradient:         { flex: 1 },
  blob1:            { position: 'absolute', width: 280, height: 280, borderRadius: 140, backgroundColor: 'rgba(255,255,255,0.05)', top: -80, right: -80 },
  blob2:            { position: 'absolute', width: 200, height: 200, borderRadius: 100, backgroundColor: 'rgba(255,255,255,0.04)', bottom: 100, left: -60 },
  scroll:           { flexGrow: 1, alignItems: 'center', paddingTop: 60, paddingBottom: 40, paddingHorizontal: 20 },

  logoArea:         { alignItems: 'center', marginBottom: 32 },
  logoBox:          { width: 72, height: 72, borderRadius: 20, backgroundColor: 'rgba(255,255,255,0.15)', alignItems: 'center', justifyContent: 'center', borderWidth: 1.5, borderColor: 'rgba(255,255,255,0.3)', marginBottom: 14 },
  brand:            { fontSize: 26, fontWeight: '800', color: colors.white, letterSpacing: 0.3 },
  tagline:          { fontSize: 12, color: 'rgba(255,255,255,0.6)', marginTop: 4, letterSpacing: 1.2, textTransform: 'uppercase' },

  card:             { width: '100%', maxWidth: 400, backgroundColor: colors.white, borderRadius: 24, padding: 28, shadowColor: '#000', shadowOffset: { width: 0, height: 10 }, shadowOpacity: 0.15, shadowRadius: 24, elevation: 16 },
  cardTitle:        { fontSize: 22, fontWeight: '800', color: colors.gray900, marginBottom: 4 },
  cardSub:          { fontSize: 13, color: colors.gray500, marginBottom: 24 },

  fieldWrap:        { marginBottom: 16 },
  label:            { fontSize: 12, fontWeight: '600', color: colors.gray700, marginBottom: 6, letterSpacing: 0.3 },
  inputRow:         { flexDirection: 'row', alignItems: 'center', borderWidth: 1.5, borderColor: colors.gray200, borderRadius: 12, backgroundColor: colors.gray50, paddingHorizontal: 12, height: 48 },
  inputIcon:        { marginRight: 8 },
  input:            { flex: 1, fontSize: 14, color: colors.gray900 },
  eyeBtn:           { padding: 4 },

  forgotWrap:       { alignItems: 'flex-end', marginBottom: 22, marginTop: -6 },
  forgotText:       { fontSize: 12, color: colors.primary, fontWeight: '600' },

  loginBtn:         { backgroundColor: colors.primary, borderRadius: 14, height: 50, alignItems: 'center', justifyContent: 'center', shadowColor: colors.primary, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.35, shadowRadius: 10, elevation: 6 },
  loginBtnDisabled: { opacity: 0.7 },
  loginBtnText:     { color: colors.white, fontSize: 15, fontWeight: '700', letterSpacing: 0.3 },

  divider:          { flexDirection: 'row', alignItems: 'center', marginVertical: 20 },
  divLine:          { flex: 1, height: 1, backgroundColor: colors.gray200 },
  divText:          { marginHorizontal: 12, fontSize: 12, color: colors.gray400, fontWeight: '500' },

  googleBtn:        { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', borderWidth: 1.5, borderColor: colors.gray200, borderRadius: 14, height: 50, backgroundColor: colors.white, gap: 10 },
  googleIcon:       { width: 24, height: 24, borderRadius: 12, backgroundColor: '#EA4335', alignItems: 'center', justifyContent: 'center' },
  googleG:          { color: colors.white, fontSize: 13, fontWeight: '800' },
  googleText:       { fontSize: 14, fontWeight: '600', color: colors.gray800 },

  demoToggle:       { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', marginTop: 20, gap: 5 },
  demoToggleText:   { fontSize: 12, color: colors.primary, fontWeight: '600' },

  hintsBox:         { marginTop: 12, borderTopWidth: 1, borderTopColor: colors.gray100, paddingTop: 12, gap: 8 },
  hintRow:          { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 10, backgroundColor: colors.gray50, borderRadius: 12 },
  hintAvatar:       { width: 34, height: 34, borderRadius: 17, backgroundColor: colors.primary + '20', alignItems: 'center', justifyContent: 'center' },
  hintAvatarText:   { fontSize: 13, fontWeight: '700', color: colors.primary },
  hintLabel:        { fontSize: 12, fontWeight: '700', color: colors.gray800 },
  hintEmail:        { fontSize: 11, color: colors.gray500, marginTop: 1 },

  footer:           { marginTop: 28, fontSize: 11, color: 'rgba(255,255,255,0.35)', letterSpacing: 0.3 },
});
