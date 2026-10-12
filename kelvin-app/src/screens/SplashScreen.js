import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { colors } from '../theme';

const { width } = Dimensions.get('window');

export default function SplashScreen() {
  const logoScale   = useRef(new Animated.Value(0.3)).current;
  const logoOpacity = useRef(new Animated.Value(0)).current;
  const textOpacity = useRef(new Animated.Value(0)).current;
  const barWidth    = useRef(new Animated.Value(0)).current;
  const tagOpacity  = useRef(new Animated.Value(0)).current;
  const ring1Scale  = useRef(new Animated.Value(0.8)).current;
  const ring1Opacity= useRef(new Animated.Value(0.6)).current;
  const ring2Scale  = useRef(new Animated.Value(0.8)).current;
  const ring2Opacity= useRef(new Animated.Value(0.4)).current;

  useEffect(() => {
    // Pulsing rings
    Animated.loop(
      Animated.sequence([
        Animated.parallel([
          Animated.timing(ring1Scale,   { toValue: 1.4, duration: 1200, useNativeDriver: true }),
          Animated.timing(ring1Opacity, { toValue: 0,   duration: 1200, useNativeDriver: true }),
        ]),
        Animated.parallel([
          Animated.timing(ring1Scale,   { toValue: 0.8, duration: 0,    useNativeDriver: true }),
          Animated.timing(ring1Opacity, { toValue: 0.6, duration: 0,    useNativeDriver: true }),
        ]),
      ])
    ).start();

    Animated.loop(
      Animated.sequence([
        Animated.delay(400),
        Animated.parallel([
          Animated.timing(ring2Scale,   { toValue: 1.4, duration: 1200, useNativeDriver: true }),
          Animated.timing(ring2Opacity, { toValue: 0,   duration: 1200, useNativeDriver: true }),
        ]),
        Animated.parallel([
          Animated.timing(ring2Scale,   { toValue: 0.8, duration: 0,    useNativeDriver: true }),
          Animated.timing(ring2Opacity, { toValue: 0.4, duration: 0,    useNativeDriver: true }),
        ]),
      ])
    ).start();

    // Logo entrance
    Animated.sequence([
      Animated.parallel([
        Animated.spring(logoScale,   { toValue: 1,   useNativeDriver: true, tension: 60, friction: 7 }),
        Animated.timing(logoOpacity, { toValue: 1,   duration: 500, useNativeDriver: true }),
      ]),
      Animated.timing(textOpacity, { toValue: 1, duration: 400, useNativeDriver: true, delay: 100 }),
      Animated.timing(tagOpacity,  { toValue: 1, duration: 300, useNativeDriver: true }),
      Animated.timing(barWidth,    { toValue: width * 0.55, duration: 1400, useNativeDriver: false }),
    ]).start();
  }, []);

  return (
    <LinearGradient colors={['#0D2B8F', '#1A56DB', '#0D2B8F']} style={styles.container} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }}>
      {/* Background decoration */}
      <View style={styles.bgCircle1} />
      <View style={styles.bgCircle2} />

      {/* Centre content */}
      <View style={styles.centre}>
        {/* Pulsing rings */}
        <Animated.View style={[styles.ring, { transform: [{ scale: ring1Scale }], opacity: ring1Opacity }]} />
        <Animated.View style={[styles.ring2, { transform: [{ scale: ring2Scale }], opacity: ring2Opacity }]} />

        {/* Logo box */}
        <Animated.View style={[styles.logoBox, { transform: [{ scale: logoScale }], opacity: logoOpacity }]}>
          <Ionicons name="flash" size={40} color={colors.white} />
        </Animated.View>

        {/* Brand name */}
        <Animated.Text style={[styles.brand, { opacity: textOpacity }]}>
          Kelvin Mech
        </Animated.Text>
        <Animated.Text style={[styles.tagline, { opacity: tagOpacity }]}>
          MEP Operations Platform
        </Animated.Text>

        {/* Loading bar */}
        <View style={styles.barTrack}>
          <Animated.View style={[styles.barFill, { width: barWidth }]} />
        </View>
        <Animated.Text style={[styles.loadingText, { opacity: tagOpacity }]}>
          Loading your workspace...
        </Animated.Text>
      </View>

      {/* Footer */}
      <Text style={styles.footer}>Powered by Ayu Ventures</Text>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container:   { flex: 1, alignItems: 'center', justifyContent: 'center' },
  bgCircle1:   { position: 'absolute', width: 300, height: 300, borderRadius: 150, backgroundColor: 'rgba(255,255,255,0.04)', top: -60, right: -80 },
  bgCircle2:   { position: 'absolute', width: 200, height: 200, borderRadius: 100, backgroundColor: 'rgba(255,255,255,0.04)', bottom: 80, left: -60 },
  centre:      { alignItems: 'center' },
  ring:        { position: 'absolute', width: 120, height: 120, borderRadius: 60, borderWidth: 2, borderColor: 'rgba(255,255,255,0.3)' },
  ring2:       { position: 'absolute', width: 160, height: 160, borderRadius: 80, borderWidth: 1.5, borderColor: 'rgba(255,255,255,0.15)' },
  logoBox:     { width: 88, height: 88, borderRadius: 24, backgroundColor: 'rgba(255,255,255,0.15)', alignItems: 'center', justifyContent: 'center', borderWidth: 1.5, borderColor: 'rgba(255,255,255,0.3)', marginBottom: 24 },
  brand:       { fontSize: 32, fontWeight: '800', color: colors.white, letterSpacing: 0.5 },
  tagline:     { fontSize: 13, color: 'rgba(255,255,255,0.65)', marginTop: 6, letterSpacing: 1.5, textTransform: 'uppercase' },
  barTrack:    { width: width * 0.55, height: 3, backgroundColor: 'rgba(255,255,255,0.15)', borderRadius: 99, marginTop: 48, overflow: 'hidden' },
  barFill:     { height: '100%', backgroundColor: 'rgba(255,255,255,0.7)', borderRadius: 99 },
  loadingText: { color: 'rgba(255,255,255,0.45)', fontSize: 11, marginTop: 12, letterSpacing: 0.5 },
  footer:      { position: 'absolute', bottom: 40, color: 'rgba(255,255,255,0.35)', fontSize: 11 },
});
