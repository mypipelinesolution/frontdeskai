import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import HomePage from './pages/HomePage'
import SuccessPage from './pages/SuccessPage'
import { ThankYou } from './pages/ThankYou'
import Pricing from './pages/Pricing'
import PartnerDashboard from './pages/PartnerDashboard'
import './index.css'

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/pricing" element={<Pricing />} />
          <Route path="/success" element={<SuccessPage />} />
          <Route path="/thank-you" element={<ThankYou />} />
          <Route path="/partner" element={<PartnerDashboard />} />
        </Routes>
      </Router>
    </AuthProvider>
  )
}

export default App