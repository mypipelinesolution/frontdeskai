import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import HomePage from './pages/HomePage'
import SuccessPage from './pages/SuccessPage'
import { ThankYou } from './pages/ThankYou'
import { PricingPage } from './pages/PricingPage'
import { LoginPage } from './pages/LoginPage'
import { SignupPage } from './pages/SignupPage'
import PartnerDashboard from './pages/PartnerDashboard'
import { WebinarBooking } from './pages/WebinarBooking'
import { WebinarRoom } from './pages/WebinarRoom'
import CleaningPage from './pages/industries/CleaningPage'
import TreePage from './pages/industries/TreePage'
import MedSpaPage from './pages/industries/MedSpaPage'
import ContractorPage from './pages/industries/ContractorPage'
import RealEstatePage from './pages/industries/RealEstatePage'
import PartnerPublicPage from './pages/PartnerPublicPage'
import EnterpriseLanding from './pages/EnterpriseLanding'
import EnterpriseReplay from './pages/EnterpriseReplay'
import EnterpriseApplication from './pages/EnterpriseApplication'
import EnterpriseOffer from './pages/EnterpriseOffer'
import './index.css'

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/signup" element={<SignupPage />} />
          <Route path="/pricing" element={<PricingPage />} />
          <Route path="/webinar" element={<WebinarBooking />} />
          <Route path="/webinar/:bookingId" element={<WebinarRoom />} />
          <Route path="/success" element={<SuccessPage />} />
          <Route path="/thank-you" element={<ThankYou />} />
          <Route path="/partner" element={<PartnerDashboard />} />

          {/* Industry Landing Pages */}
          <Route path="/industries/cleaning" element={<CleaningPage />} />
          <Route path="/industries/tree" element={<TreePage />} />
          <Route path="/industries/medspa" element={<MedSpaPage />} />
          <Route path="/industries/contractor" element={<ContractorPage />} />
          <Route path="/industries/realestate" element={<RealEstatePage />} />

          {/* Partner Public Pages */}
          <Route path="/p/:slug" element={<PartnerPublicPage />} />

          {/* Enterprise White-Label Pages */}
          <Route path="/enterprise" element={<EnterpriseLanding />} />
          <Route path="/enterprise/replay" element={<EnterpriseReplay />} />
          <Route path="/enterprise/apply" element={<EnterpriseApplication />} />
          <Route path="/enterprise/offer" element={<EnterpriseOffer />} />
        </Routes>
      </Router>
    </AuthProvider>
  )
}

export default App